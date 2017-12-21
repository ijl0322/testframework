//
//  LSPlayerCore.swift
//  Littlstar
//
//  Created by vanessa pyne on 8/10/17.
//  Copyright © 2017 vanessa pyne. All rights reserved.
//

import AVKit
import AVFoundation
import GLKit

@objc internal protocol LSPlayerCoreDelegate {
  @objc optional func lsPlayerCoreDidTap()
  @objc optional func lsPlayerCoreResume()
  @objc optional func lsPlayerCoreGetMedia() -> LSMedia?
}

class LSPlayerCore: GLKView {
  var coreDelegate: LSPlayerCoreDelegate?

  // Helpers
  var mrManager: LSMrManager!
  var gestures: LSGesture!
  var texture: LSTexture!
  var agent: LSGLAgent! = LSGLAgent()
  // GL Context
  var ctx = EAGLContext(api: .openGLES2)

  // sphere geometry
  let cols: UInt32 = 64
  let rowz: UInt32 = 64
  let r: Float = 1

  // shaders
  var yuvShaderProgram: GLuint = 0
  var rgbShaderProgram: GLuint = 1

  // video & texture
  var stereoMode: GLint = 0

  // matrices
  var rotationMatrix = GLKMatrix4MakeTranslation(0, 0, 0)
  var viewMatrix = GLKMatrix4MakeTranslation(0, 0, 0)
  var rotationQuaternion = GLKQuaternion()
  var rotationQuatX = GLKQuaternion()
  var rotationQuatY = GLKQuaternion()

  // SLERP
  let maxSlerp: Float = 0.5
  let minSlerp: Float = 0.06
  // Loop
  static var isUpdating: Bool = false {
    didSet {
      if displayLink != nil {
        if isUpdating {
          displayLink.isPaused = false
        } else {
          displayLink.isPaused = true
        }
      }
    }
  }

  //condition for AppDelegate to pause/unpause rendering
  static var displayLink: CADisplayLink!
  let frameRate = 60

  override init(frame: CGRect) {
    super.init(frame: frame)
    let ctx: EAGLContext! = EAGLContext(api: .openGLES2)
    EAGLContext.setCurrent(ctx)
    self.context = ctx
    self.delegate = self
    self.enableSetNeedsDisplay = false

    yuvShaderProgram = glCreateProgram()
    rgbShaderProgram = glCreateProgram()

    LSPlayerCore.displayLink = CADisplayLink(target: self, selector: #selector(update))
    if #available(iOS 10.0, *) {
      LSPlayerCore.displayLink.preferredFramesPerSecond = frameRate
    } else {
      LSPlayerCore.displayLink.frameInterval = 60/frameRate // native refresh frame rate is 60 FPS
    }
    LSPlayerCore.displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)

    self.drawableColorFormat = GLKViewDrawableColorFormat.RGBA8888
    self.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
    self.drawableStencilFormat = GLKViewDrawableStencilFormat.format8
    self.drawableMultisample = GLKViewDrawableMultisample.multisample4X

    // GL
    let sphereGeometry = LSSphereGeometry()
    agent.start(with: yuvShaderProgram,
                rgbProgram: rgbShaderProgram,
                verticesAndUVs: sphereGeometry.getVerticesAndUVs(),
                indices: sphereGeometry.getIndices())

    self.texture = LSTexture(context: ctx)

    // Device Motion
    mrManager = LSMrManager(fps: frameRate,
                            maxSlerp: maxSlerp,
                            minSlerp: minSlerp)
    mrManager.start()

    // Gestures
    gestures = LSGesture(minSlerp: minSlerp)
    self.addGestureRecognizer(gestures.rotationGesture)
    self.addGestureRecognizer(gestures.zoomGesture)
    self.addGestureRecognizer(gestures.panGesture)
    self.addGestureRecognizer(gestures.tapGesture)
    gestures.delegate = self
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension LSPlayerCore: GLKViewDelegate {
  internal func update() {
    let media: LSMedia! = coreDelegate?.lsPlayerCoreGetMedia?()
    if media == nil { return }

    // UPDATE TEXTURE //////////////
    var lumaVideoTexture: CVOpenGLESTexture?  // this needs to be local
    var chromaVideoTexture: CVOpenGLESTexture?  // this needs to be local

    if (media.isPlaying || media.needFirstFrame) && media.getUpdatedPixelBuffer() {
      if media.isVideo {
        self.texture.setBufferSize(pixelBufferPtr: &media.pixelBuffer!)
        self.texture.createTexture(ioSurfaceBuffer: media.pixelBuffer!,
                                   glTextureEnum: GLenum(GL_TEXTURE0),
                                   glPixelEnum: GLint(GL_RED_EXT),
                                   plane: 0,
                                   texture: &lumaVideoTexture)
        self.texture.createTexture(ioSurfaceBuffer: media.pixelBuffer!,
                                   glTextureEnum: GLenum(GL_TEXTURE1),
                                   glPixelEnum: GLint(GL_RG_EXT),
                                   plane: 1,
                                   texture: &chromaVideoTexture)
      } else if media.needFirstFrame {
        texture.createImageTexture(imageData: media.imageData!)
      }
      media.needFirstFrame = false
    }

    //// projection ////
    let cameraDegrees = abs( 90.0 - (gestures.scaleValue * 10) )
    let aspect: Float = fabsf(Float(self.bounds.size.width / self.bounds.size.height))
    var projectionMatrix = GLKMatrix4MakePerspective( ( (cameraDegrees) * .pi / 180), aspect, 0.001, 7.0)

     //// rotation ////
    // Increment SLERP during panning
    if gestures.isPanning == true && LSConstants.currentSlerp < maxSlerp {
      LSConstants.currentSlerp += (maxSlerp - minSlerp) / 8
    }

    var orientationQuaternion = GLKQuaternionConjugate(mrManager.quatFromDM)

    // Up Down
    let pitchRotation = GLKQuaternionMakeWithAngleAndAxis(gestures.translationY/gestures.dampen,
                                                         -Float(mrManager.deviceAngleVector.1),
                                                         Float(mrManager.deviceAngleVector.0),
                                                         0)
    // Sideway
    let yawRotation = GLKQuaternionMakeWithAngleAndAxis(gestures.translationX/gestures.dampen,
                                                         Float(mrManager.deviceAngleVector.0),
                                                         Float(mrManager.deviceAngleVector.1),
                                                         Float(mrManager.deviceAngleVector.2))

    let tempQuat = GLKQuaternionMultiply(pitchRotation, yawRotation)
    orientationQuaternion = GLKQuaternionMultiply(tempQuat, orientationQuaternion)

//    TODO: Cannot verify this information with data team yet, come back when they have heatmap figured out
//    let (x,y,z,w) = (orientationQuaternion.x, orientationQuaternion.y, orientationQuaternion.z, orientationQuaternion.w)
//    let roll  = atan2(2*y*w - 2*x*z, 1 - 2*y*y - 2*z*z)
//    let pitch = atan2(2*x*w - 2*y*z, 1 - 2*x*x - 2*z*z)
//    let yaw   =  asin(2*x*y + 2*z*w)
//    print("roll : \(roll), pitch : \(pitch), yaw : \(yaw)")

    self.rotationQuaternion = GLKQuaternionSlerp(self.rotationQuaternion, orientationQuaternion, LSConstants.currentSlerp)
    rotationMatrix = GLKMatrix4MakeWithQuaternion(rotationQuaternion)

    // Wait for slerp to finish before resetting pitch rotation above |1300| to 0
    gestures.clampPitchRotation()

    //// view ////
    var viewMatrix = GLKMatrix4Identity
    viewMatrix = GLKMatrix4Multiply(viewMatrix, rotationMatrix)

    //// model ////
    var modelMatrix = GLKMatrix4Identity
    let endRotateVector = GLKVector3.init(v: (1, 0, 0))
    let rotQuat = GLKQuaternionMakeWithVector3(endRotateVector, 1)
    let modelRotationMatrix = GLKMatrix4MakeWithQuaternion(rotQuat)
    modelMatrix = GLKMatrix4Multiply(modelMatrix, modelRotationMatrix)

    withUnsafePointer(to: &projectionMatrix, {
      $0.withMemoryRebound(to: GLfloat.self, capacity: 1, {(glFloatPointer) in
        glUniformMatrix4fv(agent.projectionMatrixLocation, 1, 0, glFloatPointer)
      })
    })

    withUnsafePointer(to: &viewMatrix, {
      $0.withMemoryRebound(to: GLfloat.self, capacity: 1, {(glFloatPointer) in
        glUniformMatrix4fv(agent.viewMatrixLocation, 1, 0, glFloatPointer)
      })
    })

    withUnsafePointer(to: &modelMatrix, {
      $0.withMemoryRebound(to: GLfloat.self, capacity: 1, {(glFloatPointer) in
        glUniformMatrix4fv(agent.modelMatrixLocation, 1, 0, glFloatPointer)
      })
    })
    agent.updateUniforms(self.stereoMode)
    self.display()
  }

  public func glkView(_ view: GLKView, drawIn rect: CGRect) {

    glFlush() // avoid multithreaded mishigos ? https://developer.apple.com/documentation/opengles/eaglsharegroup

    glClearColor(0.0, 0.0, 0.0, 1.0)

    glClear(GLbitfield(GL_COLOR_BUFFER_BIT)) // GL_COLOR_BUFFER_BIT == 0x00004000

    glBindVertexArray(agent.VAO)  // glBindVertexArrayOES(VAO)

    glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), agent.indicesVBO)

    glDrawElements(GLenum(GL_TRIANGLE_STRIP), GLsizei(agent.indices.count), GLenum(GL_UNSIGNED_INT), nil)
  }
}

extension LSPlayerCore: LSGestureDelegate {
  func lgGestureDidTap() {
    coreDelegate?.lsPlayerCoreDidTap?()
  }

  func lsGestureGetDeviceVector() -> (Float, Float, Float) {
    return (mrManager.deviceAngleVector.0, mrManager.deviceAngleVector.1, mrManager.deviceAngleVector.2)
  }
}
