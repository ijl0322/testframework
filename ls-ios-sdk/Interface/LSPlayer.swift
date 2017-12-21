//
//  LSPlayer.swift
//  Littlstar
//
//  Created by Huy Dao on 10/17/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//
import UIKit
import AVKit
import AVFoundation
import Lottie

//TODO: need to restrict the user from hiding menu

@objc public protocol LSPlayerDelegate {
  func lsPlayer(isBuffering: Bool)
  func lsPlayerReadyWithImage()
  func lsPlayerReadyWithVideo(duration: Double)
  func lsPlayerHasUpdated(currentTime: Double, bufferedTime: Double)
  func lsPlayerHasEnded()
  @objc optional func lsPlayerDidTap()
}

@objc open class LSPlayer: UIView {
  var lsPlayerCore: LSPlayerCore!
  var gvrPlayerCore: GVRPlayerCore!
  var media: LSMedia! = LSMedia()
  var menu: LSMenu?
  var didShowAnimation: Bool = false
  var animation: LSAnimation!
  var blackFrame: UIView!
  var isVR: Bool = false

  public var delegate: LSPlayerDelegate?
  public var isPlaying: Bool {
    get {
      return media.isPlaying
    }
  }

  public var currentTime: Double? {
    get {
      return media?.avItem?.currentTime().seconds
    }
  }

  public var duration: Double? {
    get {
      return media?.avItem?.duration.seconds
    }
  }

  public var isMuted: Bool {
    get {
      return media.avPlayer.isMuted
    }
    set(mode) {
      media.avPlayer.isMuted = mode
    }
  }

  public init(frame: CGRect, withMenu: Bool = true) {
    super.init(frame: frame)
    lsPlayerCore = LSPlayerCore(frame: frame)
    lsPlayerCore.coreDelegate = self
    media.delegate = self
    self.addSubview(lsPlayerCore)

    if withMenu {
      menu = LSMenu()
      menu!.delegate = self
      menu!.enableOrientationObserver(true)
      self.addSubview(menu!.bottomContainer)
      self.addSubview(menu!.lsBrandWatermark)
      self.addSubview(menu!.backButton)
    }

    blackFrame = UIView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
    blackFrame.backgroundColor = .black
    blackFrame.alpha = 1
    self.addSubview(blackFrame)

    animation = LSAnimation(size: self.frame.size, animationName: "lottie-star-shorter")
    animation.animationView.center = self.center
    animation.animationView.alpha = 0
    self.addSubview(animation.animationView)
  }

  // Update lsVC frame right after self.view is updated
  open override func layoutSubviews() {
    super.layoutSubviews()
    lsPlayerCore?.frame.size = self.frame.size
  }

  public func initMedia(_ file: URL, withHeatmap: Bool = false) {
    if didShowAnimation{
      removeAnimation() // In the event that the user opens the player and immediately switches to another media
    }

    media.reset()
    let urlString = file.absoluteString.uppercased()
    if  urlString.hasSuffix(".M3U8") ||
      urlString.hasSuffix(".MOV") ||
      urlString.hasSuffix(".MP4") {
      menu?.update(isVideo: true)
      media.initLSVideo(file)
      lsPlayerCore.agent.updateGLProgram(forVideo: true)
      LSAnalyticsSession.shared.videosWatched += 1
      LSAnalyticsViewSegment.shared.reset(11, heatmap: withHeatmap)
    } else {
      menu?.update(isVideo: false)
      media.initLSImage(file)
      lsPlayerCore.agent.updateGLProgram(forVideo: false)
      LSAnalyticsSession.shared.photosViewed += 1
    }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func invalidate() {
    LSAnalyticsViewSegment.shared.end(time: duration, event: .stop)
    removeAnimation()
    delegate = nil
    animation = nil

    media.reset()
    media = nil

    menu?.enableOrientationObserver(false)
    menu?.displayerTimer?.invalidate()
    menu?.displayerTimer = nil
    menu = nil

    lsPlayerCore.mrManager.stopDeviceMotionUpdates()
    LSPlayerCore.isUpdating = false
    LSPlayerCore.displayLink.invalidate()
    LSPlayerCore.displayLink = nil
    lsPlayerCore.mrManager = nil
    lsPlayerCore.gestures = nil
    lsPlayerCore.texture = nil
    lsPlayerCore.agent = nil
    lsPlayerCore.removeFromSuperview()
    lsPlayerCore = nil
  }

  public func seek(to second: Double) {
    if second >= 5.0 {
      removeAnimation() // In the event the user opens a video and immediately seeks to a specific time, we consider that the animation has been shown
    }
    media.seek(to: Int(second))
    if media.isPlaying {
      LSAnalyticsViewSegment.shared.start(time: second, event: .seek)
    }
  }

  internal func removeAnimation() {
    self.didShowAnimation = true
    self.animation?.animationView.stop()
    self.animation?.animationView.removeFromSuperview()
    self.blackFrame.alpha = 0
    animation = nil
  }

  public func playLongerAnimation(completionCallback: @escaping () -> ()) {
    animation = LSAnimation(size: self.frame.size, animationName: "lottie-star")
    self.animation.animationView.alpha = 1
    self.animation.animationView.center = self.center
    self.addSubview(animation.animationView)
    self.animation.animationView.play(completion: { (done) in
      // continue completion block only if the animation is complete
        self.removeAnimation()
        completionCallback()

    })
  }

  //MARK: - Interactive Functions
  //Override this method to implement close method
  public func close() {
    self.invalidate()

    var vc: UIViewController? {
      var parentResponder: UIResponder? = self
      while parentResponder != nil {
        parentResponder = parentResponder!.next
        if let viewController = parentResponder as? UIViewController {
          return viewController
        }
      }
      return nil
    }
    if vc != nil {
      vc!.navigationController?.popViewController(animated: true)
    }
  }

  public func play() {
    menu?.resetDisplayTimer()
    if !didShowAnimation {
      didShowAnimation = true
      DispatchQueue.main.async {
        self.animation.animationView.alpha = 1
        self.animation.animationView.play(completion: { (done) in
          if done { // continue completion block only if the animation is complete
            self.menu?.playButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
            self.menu?.playButton.tintColor = .white
            self.media.play()
            LSAnalyticsViewSegment.shared.start(time: 0, event: .play)
            UIView.animate(withDuration: 1.0, animations: {
              self.removeAnimation()
            })
          }
        })
      }
    } else {
      menu?.playButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
      menu?.playButton.tintColor = .white
      media.play()
      LSAnalyticsViewSegment.shared.start(time: 0, event: .play)
    }
  }

  public func pause() {
    menu?.playButton.setImage(#imageLiteral(resourceName: "play.png").withRenderingMode(.alwaysTemplate), for: .normal)
    menu?.playButton.tintColor = .white
    media.pause()
    LSAnalyticsViewSegment.shared.end(time: currentTime, event: .pause)
  }

  public func setVRMode(enable: Bool) {
    removeAnimation()
    var vc: UIViewController? {
      var parentResponder: UIResponder? = self
      while parentResponder != nil {
        parentResponder = parentResponder!.next
        if let viewController = parentResponder as? UIViewController {
          return viewController
        }
      }
      return nil
    }
    if vc == nil || enable == isVR {
      return
    } else {
      // Hiding the transition between vr modes
      let window = UIApplication.shared.keyWindow!
      var black: UIView! = UIView()
      var delayTime: CGFloat = 0
      black.frame.size = CGSize(width: window.frame.size.width * 5, height: window.frame.size.height * 5)
      black.backgroundColor = .black
      black.center = window.center
      window.addSubview(black)
      if enable {
        GVRPlayer.isPresented = true
        delayTime = 0.6
        LSAnalyticsViewSegment.shared.end(time: currentTime,
                                          event: .vr)
        isVR = true
        lsPlayerCore.coreDelegate = nil
        LSPlayerCore.isUpdating = false
        if media.isVideo {
          media.enableVideoEndObserver(false)
          gvrPlayerCore = GVRPlayerCore(videoWith: media.avPlayer)
        } else {
          let imageData = try? Data(contentsOf: media.imageData!)
          let image = UIImage(data: imageData!)
          gvrPlayerCore = GVRPlayerCore(imageWith: image!)
        }
        gvrPlayerCore.coreDelegate = self
        vc?.navigationController?.pushViewController(gvrPlayerCore, animated: false)
      } else if !enable {
        delayTime = 0.1
        LSAnalyticsViewSegment.shared.start(time: currentTime,
                                            event: .vr)
        isVR = false
        gvrPlayerCore.coreDelegate = nil
        gvrPlayerCore.navigationController?.popViewController(animated: false)
        LSPlayerCore.isUpdating = true
        lsPlayerCore.coreDelegate = self
        if media.isVideo {
          media.enableVideoEndObserver(true)
        }
      }

      UIView.animate(withDuration: 0.3, delay: TimeInterval(delayTime), options: .curveEaseInOut, animations: {
        black.alpha = 0
      }) { (done) in
        black.removeFromSuperview()
        black = nil
      }
    }
  }

  func stepBackward() {
    removeAnimation()
    if currentTime! <= 15.0 {
      LSAnalyticsViewSegment.shared.seek(endTime: currentTime!, startTime: 0)
      self.seek(to: 0)
    } else {
      LSAnalyticsViewSegment.shared.seek(endTime: currentTime!, startTime: currentTime! - 15)
      self.seek(to: currentTime! - 15)
    }
  }

  func stepForward() {
    removeAnimation()
    if self.currentTime! + 15.0 >= self.duration! {
      LSAnalyticsViewSegment.shared.seek(endTime: currentTime!, startTime: duration! - 1.0)
      self.seek(to: self.duration! - 1.0)
    } else {
      LSAnalyticsViewSegment.shared.seek(endTime: currentTime!, startTime: currentTime! + 15)
      self.seek(to: self.currentTime! + 15)
    }
  }
}

extension LSPlayer: LSMenuDelegate {
  internal func lsMenuSlider(seek to: Double) -> Bool{
    self.seek(to: to)
    return media.isPlaying
  }

  internal func lsMenuStep(forward: UIButton) {
    self.stepForward()
  }

  internal func lsMenuStep(backward: UIButton) {
    self.stepBackward()
  }

  internal func lsMenuTapped(play: UIView) {
    if isPlaying {
      self.pause()
    } else {
      self.play()
    }
  }

  internal func lsMenuTapped(vr: UIButton) {
    setVRMode(enable: true)
  }

  internal func lsMenuTapped(maximize: UIButton) {
    //TODO: - needs to tackle this
  }

  internal func lsMenuTapped(close: UIButton) {
    self.close()
  }
}

extension LSPlayer: LSMediaDelegate{
  internal func lsMediaReadyWithVideo(duration: Double) {
    delegate?.lsPlayerReadyWithVideo(duration: duration)

    if !isVR {
      LSPlayerCore.isUpdating = true
    }
    menu?.updateTimeLabel(duration, progressLabel: false)
    menu?.displayMenu(on: true, withHiddenTimer: false)
  }

  internal func lsMediaReadyWithImage() {
    delegate?.lsPlayerReadyWithImage()
    LSPlayerCore.isUpdating = true
  }

  internal func lsMediaHasEnded() {
    LSAnalyticsViewSegment.shared.end(time: duration, event: .finish)
    delegate?.lsPlayerHasEnded()
  }

  internal func lsMediaHasUpdated(currentTime: Double, bufferedTime: Double) {
    delegate?.lsPlayerHasUpdated(currentTime: currentTime, bufferedTime: bufferedTime)
    menu?.updateTimeLabel(currentTime, progressLabel: true)
  }


  internal func lsMedia(isBuffering: Bool) {
    delegate?.lsPlayer(isBuffering: isBuffering)
  }
}

extension LSPlayer: LSPlayerCoreDelegate {
  internal func lsPlayerCoreGetMedia() -> LSMedia? {
    return media
  }

  internal func lsPlayerCoreDidTap() {
    delegate?.lsPlayerDidTap?()
    if menu != nil {
      self.menu?.displayMenu(on: !self.menu!.isDisplaying)
    }
  }

  internal func lsPlayerCoreResume() {
    self.setVRMode(enable: false)
  }
}
