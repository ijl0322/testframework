//
//  LSVideoItem.swift
//  Littlstar Demo
//
//  Created by Huy Dao on 11/17/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import UIKit

class LSLabel: UILabel {
  var userTag: Int = 0
}

@objc class LSVideoItem: NSObject {
  var title: String!
  var desc: String!
  var bannerImage: UIImage!
  var duration = 0
  var videoURL: URL!
}

