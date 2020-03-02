//
//  HTTPService.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

public protocol HttpService {
    func sendRequest<T: Decodable>(_ request: HttpRequest) -> Promise<T>
}

open class HttpApiService: HttpService {

    let session: Session

    public init(session: Session) {
        self.session = session
    }

    public func sendRequest<T: Decodable>(_ request: HttpRequest) -> Promise<T> {
        return sendRequest(request).map { (response: HTTPURLResponse, data: Data) -> T in
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw ApiError.processing
            }
        }
    }

    public func sendRequest(_ request: Alamofire.URLRequestConvertible) -> Promise<(HTTPURLResponse, Data)> {
        self.sendRequest(request: request, retryAttempts: 3, session: self.session)
    }

    private func sendRequest(request: Alamofire.URLRequestConvertible, retryAttempts: Int, session: Session? = nil) -> Promise<(HTTPURLResponse, Data)> {
        return sendRequestInternal(request: request, session: session).recover { error -> Promise<(HTTPURLResponse, Data)> in
            switch error.type {
            case .unavailable:
                if retryAttempts > 0 {
                    return after(seconds: 3.0).then {
                        self.sendRequest(request: request, retryAttempts: retryAttempts - 1, session: session)
                    }
                }
            default: break
            }
            throw error
        }
    }

    private func sendRequestInternal(request: Alamofire.URLRequestConvertible, session: Session? = nil) -> Promise<(HTTPURLResponse, Data)> {

        let req = session == nil ? AF.request(request) : session?.request(request)

        return Promise { seal in

            req?.response { response in
                if let _ = response.error {
                    seal.reject(ApiError.connectivity)
                } else if let httpResponse = response.response, let data = response.data {
                    if let error = self.extractError(response: response, data: data) {
                        seal.reject(error)
                    } else {
                        seal.fulfill((httpResponse, data))
                    }
                } else {
                    seal.reject(ApiError.processing)
                }
            }
        }
    }

    public func extractError(response: AFDataResponse<Data?>, data: Data) -> Error? {
        guard let res = response.response else {
            return ApiError.processing
        }

        switch res.statusCode {
        case 200...203:
            return nil
        case 500, 503, 504:
            return ApiError.unavailable
        default:
            return ApiError.unknown
        }
    }
}
