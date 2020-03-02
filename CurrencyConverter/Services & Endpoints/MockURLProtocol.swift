//
//  MockURLProtocol.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 02/03/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation

final class MockURLProtocol: URLProtocol {

    enum ResponseType {
        case error(Error)
        case success(HTTPURLResponse, Bool)
    }
    static var responseType: ResponseType!

    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    private(set) var activeTask: URLSessionTask?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }

    override func startLoading() {
        activeTask = session.dataTask(with: request.urlRequest!)
        activeTask?.cancel()
    }

    override func stopLoading() {
        activeTask?.cancel()
    }
}

// MARK: - URLSessionDataDelegate
extension MockURLProtocol: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        switch MockURLProtocol.responseType {
        case .error(let error)?:
            client?.urlProtocol(self, didFailWithError: error)
        case .success(let response, let hasInvalidData)?:
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: hasInvalidData ? createInvalidData() : createMockedData())
        default:
            break
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    private func createInvalidData() -> Data {
        return "abc".data(using: .utf8)!
    }

    private func createMockedData() -> Data {
        return """
        {
            "rates": {
                "CAD": 1.4757,
                "HKD": 8.555
            }
        }
        """.data(using: .utf8)!
    }
}

extension MockURLProtocol {

    static func responseWithFailure() {
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.error(ApiError.connectivity)
    }

    static func responseWithStatusCode(code: Int?, for url: URL, hasInvalidData: Bool = false) {
        if let code = code {
            MockURLProtocol.responseType = MockURLProtocol.ResponseType.success(HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!, hasInvalidData)
        } else {
            MockURLProtocol.responseType = MockURLProtocol.ResponseType.error(ApiError.connectivity)
        }
    }
}
