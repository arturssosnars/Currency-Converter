//
//  CurrencyListTableViewController.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 01/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import UIKit

class CurrencyListTableViewController: UITableViewController {

    var uiPresenter: CurrencyListUIPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        uiPresenter = CurrencyListUIPresenter(viewController: self)
        uiPresenter?.viewDidLoad()
    }

    @IBAction func onEditPressed(_ sender: Any) {
        uiPresenter?.onEditPressed()
    }

}

