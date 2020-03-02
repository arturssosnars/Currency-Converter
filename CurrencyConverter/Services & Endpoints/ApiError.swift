//
//  ApiError.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation

public enum ApiError: Error {
    case unknown
    case unavailable
    case processing
    case connectivity
    case none

    case unhandled
}
