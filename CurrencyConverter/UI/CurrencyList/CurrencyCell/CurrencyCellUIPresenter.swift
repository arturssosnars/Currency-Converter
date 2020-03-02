//
//  CurrencyCellUIPresenter.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 01/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import UIKit

class CurrencyCellUIPresenter: NSObject {

    weak var cell: CurrencyTableViewCell?
    private var baseValue: Double = 0.0
    var activeCell: Bool = false {
        didSet {
            cell?.exchangeRateLabel.text = "1.0"
            cell?.currencyTextField.isUserInteractionEnabled = activeCell
            if activeCell {
                cell?.currencyTextField.becomeFirstResponder()
            }
        }
    }
    var currency: String = "" {
        didSet {
            cell?.currencyName.text = self.currency
        }
    }
    var exchangeRate: Double = 0.0 {
        didSet {
            updateRate()
        }
    }

    init(cell: CurrencyTableViewCell) {
        self.cell = cell
    }

    public func prepareTextFieldDelegate() {
        self.cell?.currencyTextField.delegate = self
    }

    public func updateCell(currencyName: String, rate: Double) {
        self.currency = currencyName
        self.exchangeRate = rate
        setImage()
    }

    public func updateRate() {
        cell?.exchangeRateLabel.text = "\(exchangeRate)"
        let value = String(format: "%.2f", round(100 * baseValue * self.exchangeRate) / 100)
        cell?.currencyTextField.text = "\(value)"
    }

    public func setImage() {
        guard let str = cell?.currencyName.text?.dropLast(), let imageView = cell?.flagImage else { return }
        let code = String(str)
        KFImageFetch.sharedInstance.fetchImage(imageView: imageView, countryCode: code)
    }

    public func updateAmmountValue(baseValue: Double) {
        self.baseValue = baseValue
        let calculationValue = baseValue * exchangeRate
        let value = String(format: "%.2f", round(100 * calculationValue) / 100)
        cell?.currencyTextField.text = "\(value)"
    }

    public func updateRateValue(_ value: Double) {
        self.exchangeRate = value
    }
}

extension CurrencyCellUIPresenter: UITextFieldDelegate {
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let res: String = {
            if string.isEmpty {
                return String(text.dropLast())
            } else {
                return text + string
            }
        }()
        let isValid = Double(res) != nil

        let textArray = res.components(separatedBy: ".")
        if textArray.count == 2 {
            let lastString = textArray.last
            if lastString!.count > 2 { //Check number of decimal places
                return false
            }
        }

        if isValid || res == "" {
            cell?.onCurrencyAmountChange?(Double(res) ?? 0)
        }
        guard !string.isEmpty else {
            return true
        }
        if textField.text == "0" {
            if string == "0" {
                return false
            }
            if Double(string) != nil {
                textField.text = ""
                return true
            }
        }
        return isValid
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
