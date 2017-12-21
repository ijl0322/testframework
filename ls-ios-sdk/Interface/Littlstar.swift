//
//  Littlstar.swift
//  ls-ios-sdk
//
//  Created by Huy Dao on 12/6/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import UIKit

@objc internal enum LSOrientation: Int {
  case portrait = 0
  case left = 1
  case right = 2
  case unknown = 3
}


// TODO: - still need to add note for GVRPlayer isPresented
// http://swiftiostutorials.com/ios-orientations-landscape-orientation-one-view-controller/
public class Littlstar : NSObject {
  internal static var configured = false
  internal static let SDKversion = "1.0.0"
  internal static let shared = Littlstar()
  private override init() {}

  @objc internal dynamic var orientation: LSOrientation = .unknown

  public static func configureOrientation(_ window: UIWindow?) -> UIInterfaceOrientationMask {
    if window == nil {return .portrait }
    let vc = window?.rootViewController!.presentedViewController
    if vc is GVRPlayerCore || vc is GVRPlayer || GVRPlayer.isPresented {
      return .landscapeRight
    } else {
      return .portrait
    }
  }

  public static func configure() {
    NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(_:)), name: .UIApplicationWillResignActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(willTerminate(_:)), name: .UIApplicationWillTerminate, object: nil)


    switch UIDevice.current.orientation {
    case .landscapeLeft:
      Littlstar.shared.orientation = .left
    case .landscapeRight:
      Littlstar.shared.orientation = .right
    default:
      Littlstar.shared.orientation = .portrait
    }
    Littlstar.configured = true
  }

  @objc internal static func didBecomeActive(_ notification: Notification) {
    LSAnalyticsSession.shared.reset()
    if LSPlayerCore.isUpdating {
      LSPlayerCore.displayLink?.isPaused = false //Resume updating GL
    }
  }

  @objc internal static func willResignActive(_ notification: Notification) {
    LSAnalyticsSession.shared.beginBackgroundCountdown()
    LSPlayerCore.displayLink?.isPaused = true //Stop updating GL
  }

  @objc internal static func willTerminate(_ notification: Notification) {
    LSAnalyticsSession.shared.end()
  }


}
