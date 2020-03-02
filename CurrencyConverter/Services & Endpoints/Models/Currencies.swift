//
//  Currencies.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation

public struct CurrencyWrap: Decodable {
    private var rates: [String: Double]

    enum CodingKeys: String, CodingKey{
        case rates
    }

    var sortedRates: [(String, Double)] {
        var array: [(String, Double)] = []
        for (key, value) in rates {
            array.append((key, value))
        }
        array.sort { $0.0 < $1.0 }
        return array
    }

    var sortedCurrencyNames: [String] {
        var array: [String] = []
        for (key, _) in rates {
            array.append(key)
        }
        array.sort { $0 < $1 }
        return array
    }
}
