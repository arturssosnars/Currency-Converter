//
//  CurrencyEditTableViewCell.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 01/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import UIKit

class CurrencyEditTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyName: UILabel!
    @IBOutlet weak var checkImage: UIImageView!

    func select() {
        self.checkImage.isHidden.toggle()
    }

    func isSelected() -> Bool {
        return !self.checkImage.isHidden
    }
}
