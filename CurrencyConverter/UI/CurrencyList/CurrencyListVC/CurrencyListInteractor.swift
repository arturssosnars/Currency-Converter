//
//  CurrencyListInteractor.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 01/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import PromiseKit

class CurrencyListInteractor {

    var updateTimer: Timer?
    var baseCurrency: String = UserDefaults.standard.string(forKey: "base_currency") ?? "EUR"
    public var rates: [(String, Double)] = [] {
        didSet {
            reorderAndFilterRates(rates)
        }
    }
    var filteredRates: [(String, Double)] = [] {
        didSet {
            didFilterRates(oldValue: oldValue)
        }
    }
    var onRatesSet: (() -> Void)?
    var onInitialSet: (() -> Void)?
    var onApiError: ((ApiError) -> Void)?

    init() {
        updateTimer = .scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
}

// MARK: Data management
extension CurrencyListInteractor {
    private func reorderAndFilterRates(_ array: [(String, Double)]) {
        var newArray: [(String, Double)] = []
        let activeCurrency = loadSavedCurrencyList()
        newArray.append(contentsOf: array.filter { activeCurrency.contains($0.0) })
        let index = newArray.firstIndex { (key, _) -> Bool in
            return key == baseCurrency
        }
        if let index = index {
            let element = newArray.remove(at: index)
            newArray.insert(element, at: 0)
        }
        if !hasBaseInResponse() {
            let baseValue = (baseCurrency, 1.0)
            newArray.insert(baseValue, at: 0)
        }
        filteredRates = newArray
    }

    private func loadSavedCurrencyList() -> [String] {
        let savedCurrencyList = UserDefaults.standard.array(forKey: "currency_list")
        var array: [String] = []
        for value in savedCurrencyList ?? [] {
            array.append(String(describing: value))
        }
        return array.isEmpty ? ["EUR", "USD", "GBP"] : array
    }

    @objc private func loadData() {
        let _ = ApiService().getCurrencyRates(base: baseCurrency).done { result in
            self.rates = result.sortedRates
        }.catch { error in
            if let error = error as? ApiError{
                if error == .connectivity {
                    self.updateTimer?.invalidate()
                }
                self.onApiError?(error)
            }
        }
    }

    private func hasBaseInResponse() -> Bool {
        for (key, _) in rates {
            if key == baseCurrency {
                return true
            }
        }
        return false
    }
}
    // MARK: Filter completion
extension CurrencyListInteractor {

    private func didFilterRates(oldValue: [(String, Double)]) {
        if oldValue.isEmpty {
            onInitialSet?()
        } else {
            onRatesSet?()
        }
    }
}
