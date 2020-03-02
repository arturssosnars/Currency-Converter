//
//  LoadingView.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 01/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import UIKit
import BPBlockActivityIndicator

class LoadingView: UIView {

    @IBOutlet weak var indicator: BPBlockActivityIndicator!

    override func awakeFromNib() {
        super.awakeFromNib()
        indicator.animate()
    }

}
