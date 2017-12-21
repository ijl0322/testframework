//
//  LSTexture.swift
//  Littlstar
//
//  Created by vanessa pyne on 10/16/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import GLKit

class LSTexture {
  var vidTexCachePtr: CVOpenGLESTextureCache?

  var bufferWidth: Int = 0
  var bufferWidth0: Int = 0

  var bufferHeight: Int = 0
  var bufferHeight0: Int = 0
  var bufferHeight1: Int = 0

  var bytesPerRow0: Int = 0
  var bytesPerRow1: Int = 0

  var imagePixelBufferInfo: GLKTextureInfo?

  init(context: EAGLContext) {
    let ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &self.vidTexCachePtr)
    if ret > 0 { print("error at `CVOpenGLESTextureCacheCreate`") }
  }

  func setBufferSize(pixelBufferPtr: UnsafeMutablePointer<CVPixelBuffer>) {
    let pixelBuffer = pixelBufferPtr.pointee
    bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
    bufferWidth0 = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)

    bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
    bufferHeight0 = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
    bufferHeight1 = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)

    bytesPerRow0 = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
    bytesPerRow1 = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)
  }

  func createImageTexture(imageData: URL) {
    var imagePixelBufferInfo: GLKTextureInfo?
    do {
      glGetError() // call this to clear any errors before calling GLKTextureLoader
      try imagePixelBufferInfo = GLKTextureLoader.texture(withContentsOf: imageData, options: nil)
    }
    catch {
      print("`createImageTexture` error setting image as gl texture")
      print("glGetError(): ", glGetError())
    }
    glBindTexture(GLenum(GL_TEXTURE_2D), (imagePixelBufferInfo?.name)!)
  }

  func createTexture(ioSurfaceBuffer: CVPixelBuffer?,
                     glTextureEnum: GLenum,
                     glPixelEnum: GLint,
                     plane: Int,
                     texture: UnsafeMutablePointer<CVOpenGLESTexture?>) {
    if nil != ioSurfaceBuffer && nil != self.vidTexCachePtr {
      var w: Int = bufferWidth0
      var h: Int = bufferHeight0
      if 1 == plane { // chroma texture is half size
        w = w / 2
        h = bufferHeight1
      }

      glActiveTexture(glTextureEnum)

      let cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               self.vidTexCachePtr!,
                                                               ioSurfaceBuffer!,
                                                               nil,
                                                               GLenum(GL_TEXTURE_2D),
                                                               glPixelEnum,
                                                               GLsizei(w),
                                                               GLsizei(h),
                                                               GLenum(glPixelEnum),
                                                               GLenum(GL_UNSIGNED_BYTE),
                                                               plane,
                                                               texture)
      if 0 != cvRet { print("error at `CVOpenGLESTextureCacheCreateTextureFromImage`", cvRet) }

      glBindTexture(CVOpenGLESTextureGetTarget(texture.pointee!), CVOpenGLESTextureGetName(texture.pointee!))
      glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
      glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
      glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
    }
  }
}
