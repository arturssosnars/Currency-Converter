//
//  ImageFetcher.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 27/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

protocol ImageFetcher {
    func fetchImage(imageView: UIImageView, countryCode: String)
}

class KFImageFetch: ImageFetcher {

    public static let sharedInstance = KFImageFetch()

    func fetchImage(imageView: UIImageView, countryCode: String) {
        guard let url = ApiEndpoint.flagImage(countryCode).url else { return }
        let resource = ImageResource(downloadURL: url, cacheKey: nil)
        imageView.kf.setImage(with: resource)
    }
}
