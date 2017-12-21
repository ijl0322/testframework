//
//  LSAnalyticsViewSegment.swift
//  ls-ios-sdk
//
//  Created by Huy Dao on 12/9/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation

// Documentation for LSAnalyticsViewSegment can be viewed at
// http://docs.littlstar.com/display/DATA/View+Segment

enum SegmentStart: String {
  case play = "play"
  case seek = "seek"
  case unpause = "unpause"
  case vr = "vr"
}

enum SegmentEnd: String {
  case finish = "finish"
  case pause = "pause"
  case seek = "seek"
  case stop = "stop"
  case vr = "vr"
}

internal class LSAnalyticsViewSegment {
  internal static let shared = LSAnalyticsViewSegment()
  private init() {}
  var videoId: Int?
  var heatmap: Bool = false
  private var hasPlayed = false
  private var hasFinished = false
  private var thirdParty = false

  var startTime: Int = 0
  var startTimeStamp: String = ""
  var startEvent: SegmentStart!

  func reset(_ videoId: Int?, heatmap: Bool) {
    self.videoId = videoId
    self.heatmap = heatmap
    self.hasPlayed = false
    self.hasFinished = false
    self.thirdParty = true
  }

  func seek(endTime: Double, startTime: Double) {
    end(time: endTime, event: .seek)
    start(time: startTime, event: .seek)
  }

  func start(time: Double?, event: SegmentStart) {
    if !heatmap || time == nil {
      return
    } else if videoId == nil {
      NSLog("Heatmap recording failed: LittlstarSDK requires video_id from LSVideo object")
    }

    if event == .play && hasPlayed {
      startEvent = .unpause
    } else {
      hasPlayed = true
    }

    startTime = Int(time!)
    startTimeStamp = Date().iso8601
    startEvent = event
  }

  func end(time: Double?, event: SegmentEnd) {
    if !heatmap || time == nil {
      return
    } else if videoId == nil {
      NSLog("Heatmap recording failed: LittlstarSDK requires video_id from LSVideo object")
    }
    if event == .stop && hasFinished {
      return
    } else {
      hasFinished = true
    }

    LSAnalyticsFunctions.shared.logVideoSegment(videoId: videoId!, startTime: startTime, endTime: Int(time!), startEvent: startEvent, endEvent: event, startTimestamp: startTimeStamp, thirdPartyVideo: true)
  }


}
