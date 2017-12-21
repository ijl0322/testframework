//
//  LSMrManager.swift
//  Littlstar
//
//  Created by vanessa pyne on 10/17/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import CoreMotion
import GLKit

// Device Motion
// https://www.youtube.com/watch?v=ZdGrC9S4PYA

class LSMrManager {

  var mrmanager = CMMotionManager()
  var quatFromDM: GLKQuaternion = GLKQuaternionMake(-0.5, -0.0, -0.5, 0)
  var deviceAngleVector: (Float, Float, Float) = (0.1, 0.9, 0) 

  let fps: Float!
  let maxSlerp: Float!
  let incrementRateSlerp: Float!

  init(fps: Int, maxSlerp: Float, minSlerp: Float) {
    self.fps = Float(fps)
    self.maxSlerp = maxSlerp
    self.incrementRateSlerp = (maxSlerp - minSlerp) / Float(16)
  }

  func start() {
    let queue = OperationQueue()
    if mrmanager.isDeviceMotionAvailable {
      mrmanager.deviceMotionUpdateInterval = Double(fps/1000 - 0.01)
      mrmanager.startDeviceMotionUpdates(to: queue) {
        (deviceData: CMDeviceMotion?, error: Error?) in
        if let gravity = deviceData?.gravity {
          self.deviceAngleVector = (Float(gravity.x), Float(gravity.y), Float(gravity.z))

          var newOrientation = Littlstar.shared.orientation
          // Detect orientation change
          if gravity.x >= 0.8 {
            newOrientation = .right
          } else if gravity.x <= -0.8 {
            newOrientation = .left
          } else if gravity.y <= -0.8 {
            newOrientation = .portrait
          }

          if Littlstar.shared.orientation != newOrientation {
            Littlstar.shared.orientation = newOrientation
          }
        }
        if let rotationRate = deviceData?.rotationRate {
          // Increment SLERP if the device rotates above clamped threshold
          let clampedRate = 1.0
          if abs(rotationRate.x) > clampedRate || abs(rotationRate.y) > clampedRate || abs(rotationRate.z) > clampedRate {
            if LSConstants.currentSlerp < self.maxSlerp {
              LSConstants.currentSlerp += self.incrementRateSlerp
            }
          }
        }

        if let q = deviceData?.attitude.quaternion {
          self.quatFromDM = GLKQuaternionMake(Float(q.x), Float(q.y), Float(q.z), Float(q.w))
        }
      }
    }
  }

  func stopDeviceMotionUpdates() {
    mrmanager.stopDeviceMotionUpdates()
  }
}
