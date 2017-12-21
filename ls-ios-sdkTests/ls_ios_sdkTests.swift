//
//  ls_ios_sdkTests.swift
//  ls_ios_sdkTests
//
//  Created by vanessa pyne on 10/25/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import XCTest
import GLKit
@testable import ls_ios_sdk

class ls_ios_sdkTests: XCTestCase {

  var demoApp: LSPlayer!
  var videoMedia = URL(string:"https://360.littlstar.com/production/9a74ba53-2227-4a2a-a37e-b6c58964f094/mobile_hls.m3u8")!
  var imageMedia = URL(string:"https://ls-360-media.s3.amazonaws.com/production/f6b733dc-18bc-44b4-a99f-9999b0b0d26c/lg.jpg")!

  func writeLog(m: String) -> String {
    return "|||||||||||||||||||||: " + m
  }

  override func setUp() {
    super.setUp()
    demoApp = LSPlayer(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
  }

  override func tearDown() {
    super.tearDown()
    demoApp = nil
  }

  func testTest() {
    XCTAssertEqual(true, true, writeLog(m: "Testing 1, 2, 3..."))
  }

  func testSetEAGLContext() {
    let glkView = demoApp.lsPlayerCore

    let viewContext = String(describing: type(of: glkView!.context))
    let eaglContext = String(describing: EAGLContext.self)

    XCTAssertEqual(viewContext, eaglContext, writeLog(m: "EAGLContext was not set"))
  }

  func testSetTextureLocations() {
    demoApp.initMedia(videoMedia)
    demoApp.play()

    XCTAssertGreaterThanOrEqual(demoApp.lsPlayerCore.agent.lumaTexture, 0, writeLog(m: "lumaTexture location was not set"))
    XCTAssertGreaterThanOrEqual(demoApp.lsPlayerCore.agent.chromaTexture, 0, writeLog(m: "chromaTexture location was not set"))
  }

  func test360Image() {
    demoApp.initMedia(imageMedia)
    demoApp.play()

    demoApp.lsPlayerCore.update()
    XCTAssertEqual(demoApp.media.needFirstFrame, false, writeLog(m: "media.needFirstFrame was not set"))
  }

  func test360Video() {
    demoApp.initMedia(videoMedia)
    demoApp.play()

//    repeat {
//      // wait til first frame is rendered before pausing
//      usleep(3000)
//    } while nil == demoApp.media
//    demoApp.lsPlayerCore.update()
//    XCTAssertEqual(demoApp.media.needFirstFrame, false, writeLog(m: "media.needFirstFrame was not set"))
  }
}

