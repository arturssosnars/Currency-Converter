# CurrencyConverter

 Steps before building app:
 1. pod install
 2. Pods/BPBlockActivityIndicator/CommonAnimation.swift
   change line 31-35
   case .linear: return CAMediaTimingFunctionName.linear.rawValue
   case .easeIn: return CAMediaTimingFunctionName.easeIn.rawValue
   case .easeOut: return CAMediaTimingFunctionName.easeOut.rawValue
   case .easeInOut: return CAMediaTimingFunctionName.easeInEaseOut.rawValue
   case .defaultEasing: return CAMediaTimingFunctionName.default.rawValue
   line 73
   animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: easing.rawValue))

   Pods/BPBlockActivityIndicator/BPBlockLayer.swift
   line 27
   animation.fillMode = CAMediaTimingFillMode.forwards

   Pods/BPBlockActivityIndicator/BPBlockActivityIndicator.swift
   line 115
   RunLoop.current.add(timer, forMode: .common)
 
