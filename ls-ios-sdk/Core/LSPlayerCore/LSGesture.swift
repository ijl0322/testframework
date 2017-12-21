//
//  LSGesture.swift
//  Littlstar
//
//  Created by Huy Dao on 10/10/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//
protocol LSGestureDelegate {
  func lsGestureGetDeviceVector() -> (Float, Float, Float)
  func lgGestureDidTap()
}

class LSGesture: NSObject, UIGestureRecognizerDelegate {
  var panGesture: UIPanGestureRecognizer!
  var zoomGesture: UIPinchGestureRecognizer!
  var rotationGesture: UIRotationGestureRecognizer!
  var tapGesture: UITapGestureRecognizer!
  var delegate: LSGestureDelegate?

  // Pan
  var previousX: Float = 0
  var previousY: Float = 0
  var translationX: Float = 0
  var translationY: Float = 0
  var translationXBuffer = RingBuffer<Float>(count: 8)
  var translationYBuffer = RingBuffer<Float>(count: 8)
  // Both RingBuffers must read/write after each other immediately, otherwise write is not recorded properly
  var dampen: Float = 500
  var isPanning: Bool = false
  let pitchRotationMaxValue: Float = 1300

  // Zoom
  var scaleBuffer = RingBuffer<Float>(count: 8)
  var previousScale: Float = 0
  var scaleValue: Float = 0
  let maxZoomValue: Float = 24.0
  let minZoomValue: Float = 19.5

  // Slerp Value
  let minSlerp: Float!

  init(minSlerp: Float) {
    self.minSlerp = minSlerp
    super.init()
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
    zoomGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(zoom))
    rotationGesture = UIRotationGestureRecognizer.init(target: self, action: #selector(rotate))
    tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tap))

    if !translationXBuffer.write(0.0) { print("error writing to X ring buffer") }
    if !translationYBuffer.write(0.0) { print("error writing to Y ring buffer") }
    if !scaleBuffer.write(0.0) { print("error writing to scaleDelta ring buffer") }

    panGesture.delegate = self
    zoomGesture.delegate = self
    rotationGesture.delegate = self
    tapGesture.delegate = self

    // Init values
    scaleValue = minZoomValue
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  func normalize(x: Float, y: Float) -> ((Float, Float)) {
    let deviceVector = delegate!.lsGestureGetDeviceVector()

    let thetaXY = atan2(deviceVector.0, deviceVector.1)
    var normalizedX: Float = 0 // horizontal
    var normalizedY: Float = 0 // vertical
    if thetaXY < .pi && thetaXY > .pi/2 { // Quadrant 1
      let normalizedTheta = Float((thetaXY - .pi/2) / (.pi/2))
      normalizedX = x * normalizedTheta + y * (1 - normalizedTheta)
      normalizedY = x * -(1 - normalizedTheta) + y * normalizedTheta
    } else if thetaXY > 0 && thetaXY < .pi/2{ // Quadrant 4
      let normalizedTheta = Float((thetaXY / (.pi/2)))
      normalizedX = x * -(1 - normalizedTheta) + y * normalizedTheta
      normalizedY = x * -normalizedTheta + y * -(1 - normalizedTheta)
    } else if thetaXY < 0 && thetaXY > (-.pi/2) { // Quadrant 3
      let normalizedTheta = Float((thetaXY - (-.pi/2)) / (.pi/2))
      normalizedX = x * -normalizedTheta + y * -(1 - normalizedTheta)
      normalizedY = x * (1 - normalizedTheta) + y * -normalizedTheta
    } else if thetaXY > -.pi && thetaXY < -.pi/2 { // Quadrant 2
      let normalizedTheta = Float((thetaXY - (-.pi)) / (.pi/2))
      normalizedX = x * (1 - normalizedTheta) + y * -normalizedTheta
      normalizedY = x * normalizedTheta + y * (1 - normalizedTheta)
    }

    return (normalizedX, normalizedY)
  }

  func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
    let view = gestureRecognizer.view

    if gestureRecognizer.state == .changed {
      isPanning = true

      let normalizedTranslation: (Float, Float) = normalize(x: Float(gestureRecognizer.translation(in: view).x),
                                                            y: -Float(gestureRecognizer.translation(in: view).y))

      // Translation in X
      let deltaX = normalizedTranslation.0 -  previousX
      translationX =  translationXBuffer.read()!
      if !( translationXBuffer.write( translationX + deltaX)) { print("error in writing gesture point value") }
      previousX = normalizedTranslation.0

      // Translation in Y
      let deltaY = normalizedTranslation.1 -  previousY
      translationY =  translationYBuffer.read()!
      if !( translationYBuffer.write( translationY + deltaY)) { print("error in writing gesture point value") }
      previousY = normalizedTranslation.1
    } else if gestureRecognizer.state == .ended {
      isPanning = false
      previousX = 0.0
      previousY = 0.0
      LSConstants.currentSlerp = minSlerp

      let normalizedVelocity: (Float, Float) = normalize(x: Float(gestureRecognizer.velocity(in: view).x),
                                                         y: -Float(gestureRecognizer.velocity(in: view).y))

      // Velocity in X
      var dampenedXVelocity: Float = normalizedVelocity.0/2
      if dampenedXVelocity >= 1000 || dampenedXVelocity <= -1000 {
        dampenedXVelocity = dampenedXVelocity > 0 ? 1000 : -1000
      }
      translationX =  translationXBuffer.read()! + dampenedXVelocity
      if !( translationXBuffer.write( translationX)) { print("error in writing gesture pointX value") }
      previousX = 0.0

      // Velocity in Y
      translationY =  translationYBuffer.read()! + normalizedVelocity.1/4
      if !( translationYBuffer.write( translationY)) { print("error in writing gesture pointY value") }
      previousY = 0.0
    }
  }

  func clampPitchRotation() {
    if translationY < -pitchRotationMaxValue || translationY > pitchRotationMaxValue {
      if !(translationYBuffer.write(0)) { print("error in writing gesture pointY value") } else {
        translationY = translationYBuffer.read()!
      }
      previousY = 0.0
    }
  }

  func zoom(_ gestureRecognizer: UIPinchGestureRecognizer) {
    if gestureRecognizer.state == .began {
      previousScale = Float(gestureRecognizer.scale)
    } else if gestureRecognizer.state == .changed {
      let delta = Float(gestureRecognizer.scale) -  previousScale
      scaleValue = scaleBuffer.read()!

      let gesturePoint =  scaleValue - delta
      if gesturePoint >= maxZoomValue {
        if false == scaleBuffer.write(maxZoomValue) { print("error in writing max gesture point scale/zoom value") }
      } else if gesturePoint <= minZoomValue {
        if false == scaleBuffer.write(minZoomValue) { print("error in writing min gesture point scale/zoom value") }
      } else {
        if false == scaleBuffer.write(gesturePoint) { print("error in writing gesture point scale/zoom value") }
      }
      previousScale = Float(gestureRecognizer.scale)
    }
  }

  func rotate(_ gestureRecognizer: UIRotationGestureRecognizer) {
  }

  func tap(_ gestureRecognizer: UITapGestureRecognizer) {
    delegate?.lgGestureDidTap()
  }
}
