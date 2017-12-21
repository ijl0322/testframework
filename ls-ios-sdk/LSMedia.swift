//
//  LSMedia.swift
//  Littlstar
//
//  Created by Huy Dao on 9/13/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import AVFoundation

protocol LSMediaDelegate {
  func lsMediaReadyWithVideo(duration: Double)
  func lsMediaReadyWithImage()
  func lsMediaHasEnded()
  func lsMediaHasUpdated(currentTime: Double, bufferedTime: Double)
  func lsMedia(isBuffering: Bool)
}

internal class LSMedia: NSObject {
  var audioSession = AVAudioSession.sharedInstance()
  let videoOutput = AVPlayerItemVideoOutput()
  var notificationObserver: NSObjectProtocol?
  var needFirstFrame: Bool = false // true when video is init or skipped
  var pixelBuffer: CVPixelBuffer?
  var delegate: LSMediaDelegate?
  var isBuffering: Bool = false
  var isPlaying: Bool = false
  var avPlayer = AVPlayer()
  var avItem: AVPlayerItem!
  var didPlay: Bool = false
  var isVideo: Bool = true
  var timeObserver: Timer?
  var loop: Bool = false
  var imageData: URL?

  var stereoMode: GLint = 0 // 0=ou; 1=sbs; Default to OU because it is overwhelming majority

  override init() {
    super.init()
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
                                                      with: AVAudioSessionCategoryOptions.defaultToSpeaker)
      if #available(iOS 10.0, *) {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
                                                        with: AVAudioSessionCategoryOptions.allowAirPlay)
      } else {
        // Fallback on earlier versions
      }
    }
    catch {
      print("can't default to speaker or allow airplay")
    }
  }

  func initLSImage(_ file: URL) {
    let lsImage = LSImage()
    isVideo = false
    imageData = file
    self.delegate?.lsMediaReadyWithImage()
  }

  func initLSVideo(_ file: URL) {
    let lsVideo = LSVideo()
    isVideo = true
    enableVideoEndObserver(true)
    avItem = AVPlayerItem(url: file)
    avItem!.addObserver(self, forKeyPath: LSConstants.avItemStatus,
                        options: .initial,
                        context: nil)
    avItem.add(videoOutput)
    DispatchQueue.main.async {
      self.avPlayer.replaceCurrentItem(with: self.avItem)
    }
  }

  // Called after the video is seeked which mean time observer is readded, I don't think we want that
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if avItem?.status == .readyToPlay && !didPlay{
      didPlay = true

      play()

      DispatchQueue.global(qos: .background).async {
        repeat {
          // wait til first frame is rendered before pausing
          usleep(3000)
        } while self.needFirstFrame
        self.pause()

        self.delegate?.lsMediaReadyWithVideo(duration: self.avItem.duration.seconds)
        self.timeObserver = Timer(timeInterval: 0.5, target: self, selector: #selector(self.updateAVInterval), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timeObserver!, forMode: .commonModes)
      }
    }
  }

  func videoReachedEnd(){
    delegate?.lsMediaHasEnded()
    enableVideoEndObserver(false)
    if loop { // Replay video
      avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
      avPlayer.play()
      enableVideoEndObserver(true)
    } else {
      avPlayer.pause()
    }
  }

  func enableVideoEndObserver(_ on: Bool) {
    if on {
      NotificationCenter.default.addObserver(self, selector: #selector(self.videoReachedEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    } else {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
  }

  // Remove observers to avoid strong reference
  func reset() {
    needFirstFrame = true

    // Reset Video
    didPlay = false
    timeObserver?.invalidate()
    timeObserver = nil
    avItem?.removeObserver(self, forKeyPath: LSConstants.avItemStatus)
    avItem = nil
    enableVideoEndObserver(false)

    // Reset Image
    imageData = nil
  }


  func updateAVInterval() {
    let availableT = avItem.loadedTimeRanges.count == 0 ? 0.0 : (avItem.loadedTimeRanges.last?.timeRangeValue.end.seconds)!

    if !avItem.isPlaybackLikelyToKeepUp { // AVItem is buffering
      if !isBuffering { // Call delegate and switch buffering status only once
        isBuffering = true
        delegate?.lsMedia(isBuffering: isBuffering)
      }
    } else {
      if isBuffering {
        isBuffering = false
        delegate?.lsMedia(isBuffering: isBuffering)
      }
    delegate?.lsMediaHasUpdated(currentTime: avItem.currentTime().seconds,
                                 bufferedTime: availableT)
    }
  }

  func play() {
    isPlaying = true
    avPlayer.play()
  }

  func pause() {
    isPlaying = false
    avPlayer.pause()
  }

  func seek(to second: Int) {
    let second = CMTime(seconds: Double(second), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    avPlayer.seek(to: second)
    needFirstFrame = true
  }

  func getUpdatedPixelBuffer() -> Bool {
    if self.isVideo {
      return getPixelBufferFromHLSorMP4()
    } else {
      return true
    }
  }

  func getPixelBufferFromHLSorMP4() -> Bool {
    let itemTime = avItem.currentTime()

    if let pixel = self.videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
      self.pixelBuffer = pixel
      return true
    } else {
      return false
    }
  }
}
