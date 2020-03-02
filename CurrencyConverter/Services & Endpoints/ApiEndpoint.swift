//
//  ApiEndpoint.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import Alamofire

public func == (lhs: ApiEndpoint, rhs: ApiEndpoint) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
}

public enum ApiEndpoint: HttpRequest, Equatable {

    case currencyRates(String)
    case flagImage(String)

    public var url: URL? {
        switch self {
        case .currencyRates:
            guard let baseURL = URL(string: "https://api.exchangeratesapi.io"), let url = URL(string: "latest", relativeTo: baseURL) else {
                    return nil
            }
            return url
        case .flagImage(let code):
            guard let baseURL = URL(string: "https://www.countryflags.io"), let url = URL(string: "\(code)/flat/64.png", relativeTo: baseURL) else {
                return nil
            }
            return url
        }
    }

    public var parameters: Parameters? {
        switch self {
        case .currencyRates(let base):
            return ["base": base]
        default:
            return nil
        }
    }

}
