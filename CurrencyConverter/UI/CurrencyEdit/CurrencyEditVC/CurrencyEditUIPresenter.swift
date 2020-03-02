//
//  CurrencyEditUIPresenter.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 02/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import UIKit

class CurrencyEditUIPresenter: NSObject {
    
    var onSave: (() -> Void)?
    var saveView: UIView?

    weak var viewController: CurrencyEditTableViewController?
    weak var tableView: UITableView?
    var interactor = CurrencyEditInteractor()

    init(viewController: CurrencyEditTableViewController) {
        self.viewController = viewController
        self.tableView = viewController.tableView
    }

    public func viewDidLoad() {
        interactor.loadData()
        addSaveButton()
        self.onSave = viewController?.onSave
        tableView?.delegate = self
        tableView?.dataSource = self
        interactor.onDataLoaded = { [weak self] in
            self?.tableView?.reloadData()
        }
        interactor.onApiError = { [weak self] error in
            self?.viewController?.processError(error)
        }
    }

    private func addSaveScreen() {
        saveView = SaveView.instanceFromNib(nibName: "Save")
        if let view = saveView, let frame = self.viewController?.navigationController?.view.frame {
            view.frame = frame
            self.viewController?.navigationController?.view.addSubview(view)
        }
    }
    
    public func addSaveButton() {
        let button = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveCurrencyList))
        self.viewController?.navigationItem.rightBarButtonItem = button
    }

    @objc func saveCurrencyList() {
        var currencyList: [String] = []
        currencyList.append(contentsOf: interactor.activeCurrencyList)
        UserDefaults.standard.set(currencyList, forKey: "currency_list")
        addSaveScreen()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewController?.navigationController?.popViewController(animated: true)
            self.onSave?()
            self.saveView?.removeFromSuperview()
            self.saveView = nil
        }
    }
}

// MARK: TableView delegate & dataSource
extension CurrencyEditUIPresenter: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.currencyList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEditCell", for: indexPath) as? CurrencyEditTableViewCell else { return UITableViewCell() }
        cell.currencyName.text = interactor.currencyList[indexPath.row]
        cell.checkImage.isHidden = !interactor.activeCurrencyList.contains(interactor.currencyList[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CurrencyEditTableViewCell,
            let currencyName = cell.currencyName.text else { return }
        let selected = cell.isSelected()
        switch selected {
        case true:
            if let index = interactor.activeCurrencyList.firstIndex(of: currencyName) {
                interactor.activeCurrencyList.remove(at: index)
                cell.select()
            }
        case false:
            switch interactor.activeCurrencyList.count < 10 {
            case true:
                interactor.activeCurrencyList.append(currencyName)
                cell.select()
            case false:
                let alert = UIAlertController(title: "Warning!", message: "You can only choose up to 10 different currencies", preferredStyle: .actionSheet)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.viewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
