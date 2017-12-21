//
//  LSSlider.swift
//  Littlstar Demo
//
//  Created by Huy Dao on 10/20/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import UIKit

extension UISlider {
  func createTrackingRect(_ color: UIColor) -> UIImage {
    let size = CGSize(width: 1, height: 2)
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
  
  func createTrackingCircle(_ color: UIColor, diameter: CGFloat) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fillEllipse(in: rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
  
  convenience init(progressSlider: Bool) {
    self.init()
    
    if progressSlider {
      setMinimumTrackImage(createTrackingRect(UIColor.white), for: UIControlState())
      setMaximumTrackImage(createTrackingRect(UIColor(white: 0.75, alpha: 1)), for: UIControlState())
      setThumbImage(createTrackingRect(UIColor.clear), for: UIControlState())
    } else {
      setMinimumTrackImage(createTrackingRect(UIColor.red), for: UIControlState())
      setMaximumTrackImage(createTrackingRect(UIColor.clear), for: .normal)
      setThumbImage(createTrackingCircle(UIColor.red, diameter: 14), for: UIControlState())
    }
    backgroundColor = UIColor.clear
  }
}
