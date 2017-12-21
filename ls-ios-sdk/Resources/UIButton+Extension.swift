//
//  UIButton+Extension.swift
//  ls-ios-sdk
//
//  Created by Huy Dao on 12/4/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
extension UIButton {
  convenience init(image: UIImage){
    self.init(type: .custom)
    self.setImage(image.withRenderingMode(.alwaysTemplate), for:.normal)
    self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: LSConstants.uiButtonSize, height: LSConstants.uiButtonSize))
    self.tintColor = .white
  }
}
