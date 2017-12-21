//
//  LSConstants.swift
//  Littlstar
//
//  Created by Huy Dao on 10/31/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation

internal class LSConstants {
  static var currentSlerp: Float = 0.5
  static var rotationYClamp: Float = 400
  static var uiControlsPadding: CGFloat = 15
  static var uiButtonSize: CGFloat = 50
  static var screenWidth: CGFloat = UIScreen.main.bounds.width
  static var screenHeight: CGFloat = UIScreen.main.bounds.height

  static let seekVideo: String = "SeekVideo"
  static let avItemStatus: String = "status" //String needs to be status
  static let useYUVShader: String = "UseYUVShader"
  static let useRGBShader: String = "UseRGBShader"
}
