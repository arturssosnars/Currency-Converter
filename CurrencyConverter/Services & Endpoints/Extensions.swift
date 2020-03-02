//
//  Extensions.swift
//  CurrencyConverter
//
//  Created by Arturs Sosnars on 26/02/2020.
//  Copyright © 2020 Arturs Sosnars. All rights reserved.
//

import Foundation
import UIKit

public extension Error {
    var type: ApiError {
        return (self as? ApiError) ?? .none
    }
}

extension UIView {
    class func instanceFromNib(nibName: String) -> UIView {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}

extension UIViewController {
    public func processError(_ error: ApiError) {
        switch error {
        case .connectivity:
            let connectionView = NoConnectionView.instanceFromNib(nibName: "NoConnection")
            if let view = self.navigationController?.view {
                connectionView.frame = view.frame
                view.addSubview(view)
            }
        case .unavailable:
            let alert = UIAlertController(title: "Server unavailable", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        case .processing, .unhandled, .unknown:
            let alert = UIAlertController(title: "Oops!", message: "Something went wrong", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        case .none:
            break
        }
    }
}
