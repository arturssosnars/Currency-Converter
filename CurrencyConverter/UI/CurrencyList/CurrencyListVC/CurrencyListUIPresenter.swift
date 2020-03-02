//
//  CurrencyListUIPresenter.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 01/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import UIKit

class CurrencyListUIPresenter: NSObject {

    private weak var viewController: CurrencyListTableViewController?
    private var tableView: UITableView?
    public let interactor = CurrencyListInteractor()
    var loadingView: UIView?

    init(viewController: CurrencyListTableViewController) {
        self.viewController = viewController
        self.tableView = viewController.tableView
    }

    public func viewDidLoad() {
        addLoadingScreen()
        tableView?.delegate = self
        tableView?.dataSource = self
        setupInteractor()
    }

    public func onEditPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let customViewController = storyboard.instantiateViewController(withIdentifier: "CurrencyEditTableViewController") as? CurrencyEditTableViewController else { return }
        customViewController.onSave = {
            self.tableView?.reloadData()
        }
        customViewController.uiPresenter?.interactor.baseCurrency = interactor.baseCurrency
        self.viewController?.navigationController?.pushViewController(customViewController, animated: true)
    }
    
}

//MARK: Initial setup
extension CurrencyListUIPresenter {
    private func setupInteractor() {
        interactor.onRatesSet = { [weak self] in
            self?.updateRate()
        }
        interactor.onInitialSet = { [weak self] in
            self?.tableView?.reloadData()
            self?.removeLoadingScreen()
            self?.activateInitialCell()
        }
        interactor.onApiError = { [weak self] error in
            self?.viewController?.processError(error)
        }
    }

    private func activateInitialCell() {
        guard let cell = self.tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? CurrencyTableViewCell else { return }
        cell.uiPresenter?.activeCell = true
    }
}

// MARK: Loading screen
extension CurrencyListUIPresenter {
    private func addLoadingScreen() {
        loadingView = LoadingView.instanceFromNib(nibName: "Loading")
        if let view = loadingView {
            view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
            self.viewController?.navigationController?.view.addSubview(view)
        }
    }

    private func removeLoadingScreen() {
        if let view = loadingView {
            view.removeFromSuperview()
            loadingView = nil
        }
    }
}

// MARK: TableView updates
extension CurrencyListUIPresenter {
    private func move(from: IndexPath, to: IndexPath, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView?.moveRow(at: from, to: to)
            self.tableView?.scrollToRow(at: to, at: .top, animated: true)
        }, completion: { _ in
            if let cell = self.tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? CurrencyTableViewCell {
                let value = Double(cell.currencyTextField.text ?? "") ?? 0.0
                self.updateAllCells(baseValue: value)
            }
            completion?()
        })
    }

    private func updateAllCells(baseValue: Double) {
        for i in 1 ..< (tableView?.numberOfRows(inSection: 0) ?? 0) {
            if let cell = tableView?.cellForRow(at: IndexPath(row: i, section: 0)) as? CurrencyTableViewCell {
                cell.uiPresenter?.updateAmmountValue(baseValue: baseValue)
            }
        }
    }

    private func updateRate() {
        for i in 1 ..< (tableView?.numberOfRows(inSection: 0) ?? 0) {
            if let cell = tableView?.cellForRow(at: IndexPath(row: i, section: 0)) as? CurrencyTableViewCell {
                for (key, value) in interactor.filteredRates where (cell.currencyName.text ?? "") == key {
                    cell.uiPresenter?.exchangeRate = value
                }
            }
        }
    }
}


// MARK: TableView delegate & data source
extension CurrencyListUIPresenter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.filteredRates.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as? CurrencyTableViewCell else { return UITableViewCell() }
        cell.uiPresenter = CurrencyCellUIPresenter(cell: cell)
        let rate = interactor.filteredRates[indexPath.row]
        cell.accessibilityLabel = interactor.filteredRates[indexPath.row].0
        cell.uiPresenter?.updateCell(currencyName: rate.0, rate: rate.1)
        cell.onCurrencyAmountChange = { [weak self] base in
            self?.updateAllCells(baseValue: base)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        move(from: indexPath, to: IndexPath(row: 0, section: 0)) {
            guard let editCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CurrencyTableViewCell,
                let oldEditCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CurrencyTableViewCell else { return }
            self.interactor.baseCurrency = editCell.uiPresenter?.currency ?? ""
            UserDefaults.standard.set(editCell.uiPresenter?.currency, forKey: "base_currency")
            oldEditCell.uiPresenter?.activeCell = false
            editCell.uiPresenter?.activeCell = true
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.viewController?.tableView.frame.height {
            return height / 10
        }
        return 60
    }
}
