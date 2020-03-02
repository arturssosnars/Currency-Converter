//
//  ApiService.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

public protocol ApiServiceProvider {
    func getCurrencyRates(base: String) -> Promise<CurrencyWrap>
}

final public class ApiService: NSObject, ApiServiceProvider {
    private let httpService: HttpService

    public init(session: Session? = nil) {
        self.httpService = HttpApiService(session: session ?? AF)
        super.init()
    }

    public func getCurrencyRates(base: String) -> Promise<CurrencyWrap> {
        self.httpService.sendRequest(ApiEndpoint.currencyRates(base))
    }

}
