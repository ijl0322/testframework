//
//  Date+Extension.swift
//  ls-ios-sdk
//
//  Created by Huy Dao on 12/8/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation

extension Formatter {
  // generate iso8601 date
  static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return formatter
  }()
}

extension Date {
  var iso8601: String {
    return Formatter.iso8601.string(from: self)
  }
}
