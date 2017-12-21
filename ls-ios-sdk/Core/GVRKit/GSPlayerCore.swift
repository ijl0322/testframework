//
//  GSMedia.swift
//  ls-ios-sdk
//
//  Created by Huy Dao on 11/15/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import UIKit
import AVKit

// GVRRendererViewController requires the device orientation in landscapeRight to display properly.
// It inherits the orientation from the parent ViewController (GVRPlayerCore), which is why
// shouldAutorotate and supportedInterfaceOrientations must be overriden and forced returned
// the correct value

class GVRPlayerCore: UIViewController, LSPlayerCoreDelegate {
  var player: AVPlayer!
  var image: UIImage!
  var gvrPlayer: GVRPlayer!
  weak var coreDelegate: LSPlayerCoreDelegate!

  init(videoWith player: AVPlayer) {
    self.player = player
    super.init(nibName: nil, bundle: nil)
  }

  init(imageWith image: UIImage) {
    self.image = image
    super.init(nibName: nil, bundle: nil)
  }

  required  init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override  var shouldAutorotate: Bool {
    return false
  }

  override  var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscapeRight
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black

    if player != nil {
      gvrPlayer = GVRPlayer(videoWith: player, meshType: "")
    } else if image != nil {
      gvrPlayer = GVRPlayer(imageWith: image!, meshType: "")
    }
    gvrPlayer.coreDelegate = self
    self.present(gvrPlayer, animated: false, completion: nil)
  }

  func lsPlayerCoreResume() {
    coreDelegate?.lsPlayerCoreResume?()
  }
}

class GVRPlayer: GVRRendererViewController {
  weak var coreDelegate: LSPlayerCoreDelegate!
  static var isPresented: Bool = false
  var vrButton: UIButton!

  override  var shouldAutorotate: Bool {
    return false
  }

  override  var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscapeRight
  }

  // Need to handle when player is not loaded yet
  init(videoWith player: AVPlayer, meshType: String) {
    let videoRenderer = GVRVideoRenderer()
    videoRenderer.player = player
    videoRenderer.setSphericalMeshOfRadius(50, latitudes: 12, longitudes: 24, verticalFov: 180, horizontalFov: 360, meshType: .monoscopic)
    let sceneRenderer = GVRSceneRenderer()
    sceneRenderer.renderList.add(videoRenderer)
    sceneRenderer.hidesReticle = true
    super.init(renderer: sceneRenderer)
  }

  // Need to handle when image is not loaded yet
  init(imageWith image: UIImage, meshType: String) {
    let imageRenderer = GVRImageRenderer(image: image)
    imageRenderer?.setSphericalMeshOfRadius(50, latitudes: 12, longitudes: 24, verticalFov: 180, horizontalFov: 360, meshType: .monoscopic)
    let sceneRenderer = GVRSceneRenderer()
    sceneRenderer.renderList.add(imageRenderer!)
    sceneRenderer.hidesReticle = true
    super.init(renderer: sceneRenderer)
  }

  required  init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  override  func viewDidLoad() {
    super.viewDidLoad()
    UIApplication.shared.setStatusBarHidden(true, with: .none)
    self.rendererView.vrModeEnabled = true
  }

  override func didTapVRButton() {
    GVRPlayer.isPresented = false
    self.dismiss(animated: false) {
      self.coreDelegate?.lsPlayerCoreResume?()
    }
  }

  override func didTapLSBackButton() {
    GVRPlayer.isPresented = false
    self.dismiss(animated: false) {
      self.coreDelegate?.lsPlayerCoreResume?()
    }
  }

}
