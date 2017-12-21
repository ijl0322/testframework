//
//  LSAnalyticsFunctions.swift
//  ls-ios-sdk
//
//  Created by Huy Dao on 12/6/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation

internal class LSAnalyticsFunctions {
  internal static let shared = LSAnalyticsFunctions()
  private init() {}

  func logVideoSegment(videoId: Int,
                       startTime: Int,
                       endTime: Int,
                       startEvent: SegmentStart,
                       endEvent: SegmentEnd,
                       startTimestamp: String,
                       thirdPartyVideo: Bool) {
    var package: [String: Any] = ["video_id": videoId,
                                  "start_time": startTime,
                                  "end_time": endTime,
                                  "start_timestamp": startTimestamp,
                                  "start_event": startEvent.rawValue,
                                  "end_event": endEvent.rawValue,
                                  "third_party_video": thirdPartyVideo]
    LSAnalyticsFunctions.shared.sendLogging(package: &package)

  }

  func logSession(videos: Int,
                  photos: Int,
                  duration: Int,
                  startTime: String,
                  endTime: String) {
    var package: [String: Any] = ["videos_watched": videos,
                                  "photos_viewed": photos,
                                  "duration": duration,
                                  "start_timestamp": startTime,
                                  "end_timestamp": endTime]

    if let lastSessionDate = UserDefaults.standard.value(forKey: "lssdk_last_session") as? Date {
      package["time_since_last_session"] = abs(Int(lastSessionDate.timeIntervalSinceNow))
    }
    LSAnalyticsFunctions.shared.sendLogging(package: &package)
  }

  func sendLogging(package: inout [String: Any]) {
    package["platform"] = "iOS"
    package["user_id"] = UserDefaults.standard.integer(forKey: "lssdk_user_id")
    package["user_agent"] = UIDevice().modelName
    package["sdk_version"] = Littlstar.SDKversion

    let bundleIdentifier = Bundle.main.bundleIdentifier!
    let companyName = bundleIdentifier.components(separatedBy: ".")[1].lowercased()
    if companyName != "littlstar" {
      package["third_party"] = true
      package["third_party_name"] = companyName
    }

    let deviceType: String
    let device: String
    if UIDevice.current.userInterfaceIdiom == .pad {
      deviceType = "tablet"
      device = "iPad"
    } else if UIDevice.current.userInterfaceIdiom == .tv {
      deviceType = "tv"
      device = "Apple TV"
    } else {
      deviceType = "mobile"
      device = "iPhone"
    }
    package["device_type"] = deviceType
    package["device"] = device

    var sessionID = UserDefaults.standard.string(forKey: "lssdk_uuid")
    if sessionID == nil {
      sessionID = UUID().uuidString
      let preferences = UserDefaults.standard
      preferences.setValue(sessionID, forKey: "lssdk_uuid")
      preferences.synchronize()
    }
    package["uuid"] = sessionID!

    let locale: String
    let osLocale = NSLocale.current
    if osLocale.languageCode != nil && osLocale.languageCode == "ja" {
      locale = "ja_JP"
    } else {
      locale = "en_US"
    }
    package["locale"] = locale

    let translation: String
    if osLocale.languageCode != nil  && osLocale.regionCode != nil {
      translation = "\(osLocale.languageCode!)_\(osLocale.regionCode!)"
    } else {
      translation = "en_US"
    }
    package["translation_version"] = translation

    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      package["app_version"] = version
    }

  }
}
