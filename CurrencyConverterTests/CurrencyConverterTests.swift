//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import XCTest
@testable import CurrencyConverter
@testable import Alamofire
import MockURLSession

class CurrencyConverterTests: XCTestCase {

    var apiService: ApiService?

    override func setUp() {
        super.setUp()

        let manager: Session = {
            let configuration: URLSessionConfiguration = {
                let configuration = URLSessionConfiguration.default
                configuration.protocolClasses = [MockURLProtocol.self]
                return configuration
            }()

            return Session(configuration: configuration)
        }()
        apiService = ApiService(session: manager)
        XCTAssertNotNil(apiService)
    }

    override func tearDown() {
        apiService = nil
        XCTAssertNil(apiService)
        super.tearDown()
    }

    func testFetchCurrencyData() {
        apiService = ApiService()
        let expectResponse = expectation(description: "Should return currency list")
        let promise = apiService?.getCurrencyRates(base: "USD")
        _ = promise?.done{ response in
            XCTAssertNotNil(response)
            XCTAssertNotNil(response.sortedRates)
            XCTAssertNotNil(response.sortedCurrencyNames)
            expectResponse.fulfill()
        }

        wait(for: [expectResponse], timeout: 10)
    }

    func testCurrencyEndpoint() {
        var url = ApiEndpoint.currencyRates("USD").urlRequest?.url?.absoluteString
        var expected = "https://api.exchangeratesapi.io/latest?base=USD"
        XCTAssertEqual(url, expected)

        url = ApiEndpoint.flagImage("EN").urlRequest?.url?.absoluteString
        expected = "https://www.countryflags.io/EN/flat/64.png"
        XCTAssertEqual(url, expected)
    }

    func testParsing() {
        let currencyBlock = decodedCurrencyData
        XCTAssertEqual(currencyBlock.sortedRates.first?.0, "CAD")
        XCTAssertEqual(currencyBlock.sortedRates.first?.1, 1.4757)
        XCTAssertEqual(currencyBlock.sortedRates.last?.0, "HKD")
        XCTAssertEqual(currencyBlock.sortedRates.last?.1, 8.555)
    }

    func testResponse500() {
        guard let url = ApiEndpoint.currencyRates("USD").urlRequest?.url else { return }
        MockURLProtocol.responseWithStatusCode(code: 500, for: url)
        let exp = expectation(description: "Expected to have unavailable server error")
        let promise = apiService?.getCurrencyRates(base: "USD")
        promise?.done { _ in
        }.catch { error in
            if let err = error as? ApiError, err == .unavailable {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 30)
    }

    func testResponse404() {
        guard let url = ApiEndpoint.currencyRates("USD").urlRequest?.url else { return }
        MockURLProtocol.responseWithStatusCode(code: 404, for: url)
        let exp = expectation(description: "Expected to have unavailable server error")
        let promise = apiService?.getCurrencyRates(base: "USD")
        promise?.done { _ in
        }.catch { error in
            if let err = error as? ApiError, err == .unknown {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10)
    }

    func testResponse200() {
        guard let url = ApiEndpoint.currencyRates("USD").urlRequest?.url else { return }
        MockURLProtocol.responseWithStatusCode(code: 200, for: url)
        let exp = expectation(description: "Expected to have unavailable server error")
        let promise = apiService?.getCurrencyRates(base: "USD")
        promise?.done { response in
            XCTAssertNotNil(response)
            exp.fulfill()
        }.catch { _ in
        }
        wait(for: [exp], timeout: 10)
    }

    func testNoConnectivity() {
        guard let url = ApiEndpoint.currencyRates("USD").urlRequest?.url else { return }
        MockURLProtocol.responseWithStatusCode(code: nil, for: url)
        let exp = expectation(description: "Expected to have unavailable server error")
        let promise = apiService?.getCurrencyRates(base: "USD")
        promise?.done { _ in
        }.catch { error in
            if let err = error as? ApiError, err == .connectivity {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10)
    }

    func testInvalidData() {
        guard let url = ApiEndpoint.currencyRates("USD").urlRequest?.url else { return }
        MockURLProtocol.responseWithStatusCode(code: 200, for: url, hasInvalidData: true)
        let exp = expectation(description: "Expected to have unavailable server error")
        let promise = apiService?.getCurrencyRates(base: "USD")
        promise?.done { _ in
        }.catch { error in
            if let err = error as? ApiError, err == .processing {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10)
    }

    var decodedCurrencyData: CurrencyWrap {
        let data = """
        {
            "rates": {
                "CAD": 1.4757,
                "HKD": 8.555
            }
        }
        """.data(using: .utf8)
        let responseBlock = try! JSONDecoder().decode(CurrencyWrap.self, from: data!)
        return responseBlock
    }
}
