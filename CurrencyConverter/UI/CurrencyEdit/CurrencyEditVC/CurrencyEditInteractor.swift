//
//  CurrencyEditInteractor.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 02/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation

class CurrencyEditInteractor {

    var currencyList: [String] = []
    var activeCurrencyList: [String] = []
    var onDataLoaded: (() -> Void)?
    var onApiError: ((ApiError) -> Void)?
    var baseCurrency: String?

    public func loadSavedCurrencyList() -> [String] {
        let savedCurrencyList = UserDefaults.standard.array(forKey: "currency_list")
        var array: [String] = []
        for value in savedCurrencyList ?? [] {
            array.append(String(describing: value))
        }
        return array.isEmpty ? ["EUR", "USD", "GBP"] : array
    }

    public func loadData() {
        let _ = ApiService().getCurrencyRates(base: "USD").done { result in
            self.currencyList = result.sortedCurrencyNames
            self.activeCurrencyList = self.loadSavedCurrencyList()
            self.onDataLoaded?()
        }.catch { error in
            if let error = error as? ApiError {
                self.onApiError?(error)
            }
        }
    }

    
}
