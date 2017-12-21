//
//  LSAnalyticsSession.swift
//  ls-ios-sdk
//
//  Created by Huy Dao on 12/7/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation

// Documentation for LSAnalyticsSession can be viewed at
// http://docs.littlstar.com/display/DATA/Session

internal class LSAnalyticsSession {
  internal static let shared = LSAnalyticsSession()
  private init() {}
  var videosWatched: Int = 0
  var photosViewed: Int = 0
  var startTime: Date = Date()
  var endTime: String = ""

  var sendTimer: Timer?
  private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

  func reset() {
    registerBackgroundTask()

    if sendTimer == nil {
      startTime = Date()
      videosWatched = 0
      photosViewed = 0
    } else {
      sendTimer?.invalidate()
      sendTimer = nil
    }
  }

  func end() {
    LSAnalyticsFunctions.shared.logSession(videos: videosWatched,
                                  photos: photosViewed,
                                  duration: Int(fabs(startTime.timeIntervalSinceNow)),
                                  startTime: startTime.iso8601, endTime: Date().iso8601)
    UserDefaults.standard.set(Date(), forKey: "lssdk_last_session")
  }

  func registerBackgroundTask() {
    endBackgroundTask()
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }
  }

  func beginBackgroundCountdown() {
    sendTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(checkAvailableTime), userInfo: nil, repeats: true)
    RunLoop.main.add(sendTimer!, forMode: .commonModes)
  }

  @objc func checkAvailableTime() {
    if UIApplication.shared.backgroundTimeRemaining <= 15 {
      end()
      sendTimer?.invalidate()
      sendTimer = nil
    }
  }

  func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = UIBackgroundTaskInvalid
  }

}
