//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var currencyName: UILabel!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    var uiPresenter: CurrencyCellUIPresenter? {
        didSet {
            uiPresenter?.prepareTextFieldDelegate()
        }
    }
    var onCurrencyAmountChange: ((Double) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        currencyTextField.text = "0.00"
    }

}
