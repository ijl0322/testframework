//
//  LSBumperAnimation.swift
//  Littlstar
//
//  Created by vanessa pyne on 10/18/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import Lottie

class LSAnimation: NSObject {
  var animationView: LOTAnimationView!

  init(size: CGSize,
       animationName: String) {
    super.init()
    animationView = LOTAnimationView(name: animationName, bundle: Bundle(for: LSAnimation.self))
    animationView.frame.size = size
    animationView.loopAnimation = false
    animationView.contentMode = .scaleAspectFill
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
