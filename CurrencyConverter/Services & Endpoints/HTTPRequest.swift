//
//  HttpRequest.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public protocol HttpRequest: Alamofire.URLRequestConvertible {

    var url: URL? { get }

    var parameters: Parameters? { get }
}

extension HttpRequest {

    public func asURLRequest() throws -> URLRequest {
        guard let url = self.url else {
            throw ApiError.unhandled
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue

        return try URLEncoding.default.encode(urlRequest, with: self.parameters)
    }
}
