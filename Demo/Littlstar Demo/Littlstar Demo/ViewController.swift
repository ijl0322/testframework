//
//  ViewController.swift
//  Littlstar Demo
//
//  Created by Huy Dao on 10/18/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import UIKit
import ls_ios_sdk

@objc class ViewController: UIViewController {
  weak var player: LSPlayer!

  var muteButton: UIButton!

  var currentURL: URL!
  var indicator: UIActivityIndicatorView!
  var controlHiddenTimer: Timer!
  var bottomUIView: UIView!
  var bottomRect: CGRect!
  var shouldDisplayControl: Bool = false {
    didSet {
      if self.shouldDisplayControl {
        DispatchQueue.main.async(execute: {
          UIView.animate(withDuration: 0.3, animations: {
          })
        })
        if #available(iOS 10.0, *) {
          controlHiddenTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: false, block: { (timer) in
            self.shouldDisplayControl = false
          })
        }
      } else {
        controlHiddenTimer?.invalidate()
        controlHiddenTimer = nil
        UIView.animate(withDuration: 0.3, animations: {
        })
      }
    }
  }

  init(url: URL) {
    self.currentURL = url
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: nil) { (_) in
      UIView.setAnimationsEnabled(true)
    }
    UIView.setAnimationsEnabled(false)
    super.viewWillTransition(to: size, with: coordinator)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.isHidden = true
    UIApplication.shared.setStatusBarHidden(true, with: .none)

    player = LSPlayer(frame: self.view.frame)
    player.delegate = self
    self.view.addSubview(player)

//    indicator = UIActivityIndicatorView()
//    indicator.activityIndicatorViewStyle = .white
//    indicator.hidesWhenStopped = true
//    indicator.startAnimating()
//    indicator.center = view.center
//    self.view.addSubview(indicator)

//    NotificationCenter.default.addObserver(self,
//      selector: "orientationChanged",
//      name: NSNotification.Name.UIDeviceOrientationDidChange,
//      object: nil)

    if URL(string: "sideload") != currentURL {
      player.initMedia(currentURL, withHeatmap: true)
    }
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // FUNCTIONS
  func initMedia(media: URL) {
  }
}

extension ViewController: LSPlayerDelegate {
  func lsPlayer(isBuffering: Bool) {
//    if isBuffering {
//      indicator.startAnimating()
//    } else {
//      indicator.stopAnimating()
//    }
  }

  func lsPlayerReadyWithImage() {
    player.play()
  }

  // TODO: Main thread warning is not supposed to happen, check in player, may have to put main.async there
  func lsPlayerReadyWithVideo(duration: Double) {
    player.play()
  }

  func lsPlayerHasUpdated(currentTime: Double, bufferedTime: Double) {
  }

  func lsPlayerHasEnded() {
    player.playLongerAnimation {
      self.player.close()
    }
  }

  func lsPlayerDidTap() {
    if shouldDisplayControl {
      shouldDisplayControl = false
    } else {
      shouldDisplayControl = true
    }
  }
}
