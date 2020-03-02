//
//  CurrencyEditTableViewController.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 01/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import UIKit

class CurrencyEditTableViewController: UITableViewController {
    
    var uiPresenter: CurrencyEditUIPresenter?
    var onSave: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        uiPresenter = CurrencyEditUIPresenter(viewController: self)
        uiPresenter?.viewDidLoad()
    }

}
