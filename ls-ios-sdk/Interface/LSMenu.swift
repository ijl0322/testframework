//
//  UIButtons.swift
//  Littlstar Demo
//
//  Created by vanessa pyne on 11/20/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import UIKit
@objc internal protocol LSMenuDelegate {
  func lsMenuTapped(play: UIView)
  func lsMenuTapped(vr: UIButton)
  func lsMenuTapped(maximize: UIButton)
  func lsMenuTapped(close: UIButton)
  func lsMenuStep(forward: UIButton)
  func lsMenuStep(backward: UIButton)

  //Returned value is Media.isPlaying
  @discardableResult func lsMenuSlider(seek to: Double) -> Bool
}

internal class LSMenu: NSObject {
  enum OrientationState: Int {
    case custom = 10
    case portrait = 1
    case left = 3
    case right = 4
  }

  enum ButtonTag: Int {
    case close = 1
    case vr = 2
    case maximize = 3
    case play = 4
  }
  var delegate: LSMenuDelegate?
  let bottomContainerHeight: CGFloat = 50
  var bottomContainer: UIView!
  var playButton: UIButton!
  var vrButton: UIButton!
  var stepBackwardButton: UIButton!
  var stepForwardButton: UIButton!
  var timeProgressLabel: UILabel!
  var timeDurationLabel: UILabel!
  var timeProgressSlider: UISlider!
  var timeSlider: UISlider!
  var backButton: UIButton!
  var lsBrandWatermark: UIImageView!
  var isVideo: Bool = true // video or image
  var isSeeking: Bool = false

  var alpha: CGFloat = 1 {
    willSet (newValue){
      DispatchQueue.main.async {
        self.lsBrandWatermark?.alpha = newValue * 0.3
        self.backButton?.alpha = newValue
        self.bottomContainer?.alpha = newValue
      }
    }
  }

  var isDisplaying: Bool = true
  let menuDisplayDuration: Double = 0.3
  let menuDisplayInterval: Double = 5.0
  var displayerTimer: Timer?

  override init() {
    super.init()
    // Initialize all views without adjusting frames and orientations
    bottomContainer = UIView(frame: CGRect(x: 0, y: 0, width: LSConstants.uiButtonSize, height: bottomContainerHeight ))
    bottomContainer.layer.cornerRadius = 8
    bottomContainer.backgroundColor = UIColor(white: 0, alpha: 0.5)

    let littlstarSDKbundle = Bundle(for: type(of: self))
    let bundleURL = littlstarSDKbundle.url(forResource: "LittlstarSDK", withExtension: "bundle")
    let bundle = Bundle(url: bundleURL!)!

    // Step back Button
    stepBackwardButton = UIButton(image: UIImage(named: "step_back_24dp", in: bundle, compatibleWith: nil)!)
    stepBackwardButton.addTarget(delegate, action: #selector(delegate?.lsMenuStep(backward:)), for: .touchUpInside)
    bottomContainer.addSubview(stepBackwardButton)

    // Play Button
    playButton = UIButton(image: UIImage(named: "pause_24dp", in: bundle, compatibleWith: nil)!)
    playButton.frame.origin.x = stepBackwardButton.frame.maxX
    playButton.addTarget(delegate, action: #selector(delegate?.lsMenuTapped(play:)), for: .touchUpInside)
    bottomContainer.addSubview(playButton)

    // Step forward button
    stepForwardButton = UIButton(image: UIImage(named: "forward_24dp", in: bundle, compatibleWith: nil)!)
    stepForwardButton.frame.origin.x = playButton.frame.maxX
    stepForwardButton.addTarget(delegate, action: #selector(delegate?.lsMenuStep(forward:)), for: .touchUpInside)
    bottomContainer.addSubview(stepForwardButton)

    // Time progress label
    timeProgressLabel = UILabel()
    timeProgressLabel?.textColor = UIColor.white
    timeProgressLabel?.textAlignment = .left
    timeProgressLabel?.text = " --:-- "
    timeProgressLabel?.sizeToFit()
    timeProgressLabel?.center.y = bottomContainerHeight/2
    bottomContainer.addSubview(timeProgressLabel)

    // Time duration label
    timeDurationLabel = UILabel()
    timeDurationLabel?.textColor = UIColor.white
    timeDurationLabel?.textAlignment = .right
    timeDurationLabel?.text = " --:-- "
    timeDurationLabel?.sizeToFit()
    timeDurationLabel?.center.y = bottomContainerHeight/2
    bottomContainer.addSubview(timeDurationLabel)

    // Time progress Slider
    timeProgressSlider = UISlider(progressSlider: true)
    timeProgressSlider?.maximumValue = 0
    bottomContainer.addSubview(timeProgressSlider)

    // Time Slider
    timeSlider = UISlider(progressSlider: false)
    timeSlider?.addTarget(self, action: #selector(endSeeking), for: .touchUpInside)
    timeSlider?.addTarget(self, action: #selector(endSeeking), for: .touchUpOutside)
    timeSlider.addTarget(self, action: #selector(beginSeeking), for: .touchDown)
    timeSlider?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSlider(gesture:))))
    bottomContainer.addSubview(timeSlider)

    // VR Button
    vrButton = UIButton(image: UIImage(named: "vr", in: bundle, compatibleWith: nil)!)
    vrButton.contentEdgeInsets = UIEdgeInsets(top: LSConstants.uiControlsPadding,
                                              left: LSConstants.uiControlsPadding,
                                              bottom: LSConstants.uiControlsPadding,
                                              right: LSConstants.uiControlsPadding)
    vrButton.addTarget(delegate, action: #selector(delegate?.lsMenuTapped(vr:)), for: .touchUpInside)
    vrButton.frame.origin.x = -50
    bottomContainer.addSubview(vrButton)

    // BACK
    backButton = UIButton(image: UIImage(named: "back_24dp", in: bundle, compatibleWith: nil)!)
    backButton.addTarget(delegate, action: #selector(delegate?.lsMenuTapped(close:)), for: .touchUpInside)

    // LS Brand
    lsBrandWatermark = UIImageView(image: UIImage(named: "littlstar_24dp", in: bundle, compatibleWith: nil)!)
    lsBrandWatermark.frame.size = CGSize(width: 150, height: LSConstants.uiButtonSize)
    lsBrandWatermark.contentMode = .scaleAspectFit

    self.updateOrientation()
  }

  func resetDisplayTimer() {
    displayerTimer?.invalidate()
    displayerTimer = nil
    displayerTimer = Timer(timeInterval: menuDisplayInterval, target: self, selector: #selector(self.hideMenuWithTimer), userInfo: nil, repeats: false)
    RunLoop.main.add(displayerTimer!, forMode: .commonModes)
  }

  func hideMenuWithTimer() {
    displayMenu(on: false)

  }

  func displayMenu(on: Bool, withHiddenTimer: Bool = true) { //withHiddenTimer arg is only used when displayMenu is on
    displayerTimer?.invalidate()
    displayerTimer = nil

    DispatchQueue.main.async {
      if on {
        UIView.animate(withDuration: self.menuDisplayDuration, animations: {
          self.bottomContainer.alpha = 1
          self.backButton.alpha = 1
          self.lsBrandWatermark.alpha = 0.30
        }) { (done) in
          self.isDisplaying = true
          if withHiddenTimer {
            self.resetDisplayTimer()
          }
        }
      } else {
        UIView.animate(withDuration: self.menuDisplayDuration, animations: {
          self.bottomContainer.alpha = 0
          self.backButton.alpha = 0
          self.lsBrandWatermark.alpha = 0
        }) { (done) in
          self.isDisplaying = false
        }
      }
    }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    DispatchQueue.main.async {
      self.updateOrientation()
      self.resetDisplayTimer()
     }
  }

  func updateOrientation() {
    var menuWidth: CGFloat = 0

    switch Littlstar.shared.orientation {
    case .unknown:
      //TODO: - need to handle interface for custom view
      break
    case .portrait:
      stepForwardButton.isHidden = true
      stepBackwardButton.isHidden = true
      menuWidth = LSConstants.screenWidth - 16
      bottomContainer?.transform = CGAffineTransform(rotationAngle: 0)
      lsBrandWatermark?.transform = CGAffineTransform(rotationAngle: 0)
      backButton?.transform = CGAffineTransform(rotationAngle: 0)
      bottomContainer?.frame = CGRect(x: 8, y: LSConstants.screenHeight - bottomContainerHeight - 8, width: menuWidth, height: bottomContainerHeight)
      lsBrandWatermark?.frame.origin = CGPoint(x: LSConstants.screenWidth - lsBrandWatermark!.frame.width - 16, y: 8)
      backButton.frame.origin = CGPoint(x: 8, y: 8)
      playButton.frame.origin.x = 0
      timeProgressLabel?.frame.origin.x = playButton.frame.maxX + 4
      timeDurationLabel.frame.origin.x = menuWidth - 50 - timeDurationLabel.frame.width - 4
    case .left:
      menuWidth = LSConstants.screenHeight - 16
      bottomContainer?.transform = CGAffineTransform(rotationAngle: .pi/2)
      lsBrandWatermark?.transform = CGAffineTransform(rotationAngle: .pi/2)
      backButton?.transform = CGAffineTransform(rotationAngle: .pi/2)
      bottomContainer?.frame = CGRect(x: 8, y: 8, width: bottomContainerHeight, height: menuWidth)
      stepBackwardButton.isHidden = false
      stepForwardButton.isHidden = false
      lsBrandWatermark?.frame.origin = CGPoint(x: LSConstants.screenWidth - lsBrandWatermark!.frame.width - 8, y: LSConstants.screenHeight - lsBrandWatermark!.frame.height - 16)
      backButton.frame.origin = CGPoint(x: LSConstants.screenWidth - backButton.frame.width - 8, y: 8)
      playButton.frame.origin.x = stepBackwardButton.frame.maxX
      timeProgressLabel?.frame.origin.x = stepForwardButton.frame.maxX + 20
      timeDurationLabel.frame.origin.x = menuWidth - 50 - timeDurationLabel.frame.width - 20
    case .right:
      menuWidth = LSConstants.screenHeight - 16
      bottomContainer?.transform = CGAffineTransform(rotationAngle: -.pi/2)
      lsBrandWatermark?.transform = CGAffineTransform(rotationAngle: -.pi/2)
      backButton?.transform = CGAffineTransform(rotationAngle: -.pi/2)
      bottomContainer?.frame = CGRect(x: LSConstants.screenWidth - bottomContainerHeight - 8, y: 8, width: bottomContainerHeight, height: menuWidth)
      stepBackwardButton.isHidden = false
      stepForwardButton.isHidden = false
      lsBrandWatermark?.frame.origin = CGPoint(x: 8, y: 0 + 8)
      backButton.frame.origin = CGPoint(x: 8, y: LSConstants.screenHeight - backButton.frame.width - 8)
      playButton.frame.origin.x = stepBackwardButton.frame.maxX
      timeProgressLabel?.frame.origin.x = stepForwardButton.frame.maxX + 20
      timeDurationLabel.frame.origin.x = menuWidth - 50 - timeDurationLabel.frame.width - 20
    }

    timeSlider.frame = CGRect(x: timeProgressLabel.frame.maxX, y: 0, width: timeDurationLabel.frame.minX - timeProgressLabel.frame.maxX, height: LSConstants.uiButtonSize)
    timeProgressSlider.frame = timeSlider.frame

    //Remove vr button if the device is not phone
    if UIDevice.current.userInterfaceIdiom != .pad {
      vrButton.frame.origin.x = max(bottomContainer.frame.width, bottomContainer.frame.height) - vrButton.frame.size.width
    }

    if !isVideo {
      stepBackwardButton.isHidden = true
      stepForwardButton.isHidden = true
    }
  }

  func enableOrientationObserver(_ on: Bool) {
    if on {
      Littlstar.shared.addObserver(self, forKeyPath: #keyPath(Littlstar.orientation), options: .new, context: nil)
    } else {
      Littlstar.shared.removeObserver(self, forKeyPath: #keyPath(Littlstar.orientation))
    }
  }

  func update(isVideo: Bool) {
    self.isVideo = isVideo
    stepBackwardButton.isHidden = true
    stepForwardButton.isHidden = true
    playButton.isHidden = !isVideo
    timeProgressLabel.isHidden = !isVideo
    timeDurationLabel.isHidden = !isVideo
    timeProgressSlider.isHidden = !isVideo
    timeSlider.isHidden = !isVideo

    if isVideo {
      bottomContainer?.backgroundColor = UIColor(white: 0, alpha: 0.3)
    } else if !isVideo {
      bottomContainer?.backgroundColor = UIColor(white: 0, alpha: 0)
    }
  }


  func updateTimeLabel(_ totalSeconds: Double, progressLabel: Bool){
    let minutes = Int(totalSeconds / 60)
    let seconds = Int(Int(totalSeconds) % 60)
    DispatchQueue.main.async {
      if progressLabel && !self.isSeeking {
        self.timeProgressLabel.text = String(format: " %d:%02d ", minutes, seconds)
        self.timeSlider.setValue(Float(totalSeconds), animated: true)
      } else if !progressLabel {
        self.timeDurationLabel.text = String(format: " %d:%02d ", minutes, seconds)
        self.timeDurationLabel.sizeToFit()
        self.timeSlider.maximumValue = Float(totalSeconds)
      }
    }
  }

  func endSeeking() {
    resetDisplayTimer()
    isSeeking = false

    if delegate != nil {
      if !delegate!.lsMenuSlider(seek: Double(timeSlider.value)) {
         LSAnalyticsViewSegment.shared.end(time: Double(timeSlider.value), event: .seek)
      }
    }
  }

  func beginSeeking() {
    displayerTimer?.invalidate()
    displayerTimer = nil
    isSeeking = true
  }

  func tappedSlider(gesture: UIGestureRecognizer) {
    resetDisplayTimer()
    // Slider is confused between gesture and touch event
    // Determine whether if the user is seeking to adjust the slider
    if isSeeking {
      delegate?.lsMenuSlider(seek: Double(timeSlider.value))
    } else {
      let point = gesture.location(in: timeSlider)
      let percentage = point.x/timeSlider.bounds.size.width
      let delta = percentage * CGFloat(timeSlider.maximumValue - timeSlider.minimumValue)
      let value = CGFloat(timeSlider.minimumValue) + delta
      updateTimeLabel(Double(value), progressLabel: true)
      delegate?.lsMenuSlider(seek: Double(value))
    }
    isSeeking = false
  }

  func buttonTapped(button: UIButton) {
    resetDisplayTimer()
    switch ButtonTag(rawValue: button.tag)! {
    case .close:
      delegate?.lsMenuTapped(close: button)
    case .vr:
      delegate?.lsMenuTapped(vr: button)
    case .play:
      delegate?.lsMenuTapped(play: button)
    case .maximize:
      delegate?.lsMenuTapped(maximize: button)
    }
  }
}
