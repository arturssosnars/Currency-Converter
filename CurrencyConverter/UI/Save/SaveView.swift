//
//  SaveView.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 02/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import UIKit
import BPBlockActivityIndicator

class SaveView: UIView {

    @IBOutlet weak var indicator: BPBlockActivityIndicator!

    override func awakeFromNib() {
        super.awakeFromNib()
        indicator.animate()
    }

}
