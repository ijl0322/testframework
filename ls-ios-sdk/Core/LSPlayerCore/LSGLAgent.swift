//
//  LSGLAgent.swift
//  Littlstar
//
//  Created by Huy Dao on 9/11/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import GLKit

class LSGLAgent: NSObject {
  var VAO:GLuint = 0
  var indicesVBO: GLuint = 1
  var indices: [GLuint] = []
  var verticesAndUVsVBO: GLuint = 0

  // matrices
  var projectionMatrixLocation: GLint = 0
  var modelMatrixLocation: GLint = 0
  var viewMatrixLocation: GLint = 0
  var stereoModeLocation: GLint = 0

  // textures
  var lumaTexture: GLint = -1
  var chromaTexture: GLint = -1

  var yuvProgram: GLuint = 5
  var rgbProgram: GLuint = 6

  var vertexShader: GLuint = 0
  var fragmentShader: GLuint = 0
  var rgbVertexShader: GLuint = 0
  var rgbFragmentShader: GLuint = 0

  func start(with yuvProgram: GLuint, rgbProgram: GLuint, verticesAndUVs: [GLfloat], indices: [GLuint]) {
    self.indices = indices
    self.yuvProgram = yuvProgram
    self.rgbProgram = rgbProgram

    //////  V A O  //////
    glGenVertexArrays(1, &VAO)
    glBindVertexArray(VAO)

    ////// VERTICES UV COORDS VBO //////
    glGenBuffers(1, &verticesAndUVsVBO)
    glBindBuffer(GLenum(GL_ARRAY_BUFFER), verticesAndUVsVBO)
    glBufferData(GLenum(GL_ARRAY_BUFFER),
                 MemoryLayout<GLfloat>.stride * verticesAndUVs.count,
                 verticesAndUVs, GLenum(GL_STATIC_DRAW))

    // UVs
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 5), ls_bufferOffset(0))
    // Vertices
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 5), ls_bufferOffset(MemoryLayout<GLfloat>.stride * 2))

    ////// INDICES VBO //////
    glGenBuffers(1, &indicesVBO)
    glBindBuffer((GLenum(GL_ELEMENT_ARRAY_BUFFER)), indicesVBO)
    glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                 MemoryLayout<GLuint>.stride * indices.count,
                 indices, GLenum(GL_STATIC_DRAW))

    ////// SHADERS //////
    vertexShader = GLuint.createShader(with: yuvProgram, type: .vertex, filename: "vs")
    fragmentShader = GLuint.createShader(with: yuvProgram, type: .fragment, filename: "yuvfs")
    rgbVertexShader = GLuint.createShader(with: rgbProgram, type: .vertex, filename: "vs")
    rgbFragmentShader = GLuint.createShader(with: rgbProgram, type: .fragment, filename: "rgbfs")
  }



  func updateUniforms(_ stereoMode: GLint) {
    glUniform1i(lumaTexture, 0)
    glUniform1i(chromaTexture, 1)
    glUniform1i(stereoModeLocation, stereoMode)
  }

  func updateGLProgram(forVideo: Bool) {
    var program: GLuint = 0
    if forVideo {
      program = yuvProgram
    } else {
      program = rgbProgram
    }

    glLinkProgram(program)
    glUseProgram(program)

    projectionMatrixLocation = glGetUniformLocation(program, "projectionMatrix")
    modelMatrixLocation = glGetUniformLocation(program, "modelMatrix")
    viewMatrixLocation = glGetUniformLocation(program, "viewMatrix")
    stereoModeLocation = glGetUniformLocation(program, "stereoMode")

    lumaTexture = glGetUniformLocation(program, "lumaTexture")
    chromaTexture = glGetUniformLocation(program, "chromaTexture")
  }
}

extension GLuint {
  enum ShaderType {
    case vertex
    case fragment
  }

  static func createShader(with program: GLuint, type: ShaderType, filename: String) -> GLuint{
    var shaderString: String!
    var shader: GLuint!
    let bundle = Bundle(for: LSGLAgent.self)
    let file = bundle.path(forResource: filename, ofType: "glsl")
    if type == .vertex {
      do {
        shaderString = try String(contentsOfFile: file!)
        shader = glCreateShader(GLenum(GL_VERTEX_SHADER))
      } catch{
        print("\nCannot read the \(filename) \(type) shader file.\n")
      }
    } else {
      do {
        shaderString = try String(contentsOfFile: file!)
        shader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
      } catch{
        print("\nCannot read the \(filename) \(type) shader file.\n")
      }
    }

    let shaderStringUTF8 = shaderString.cString(using: String.defaultCStringEncoding)
    var shaderStringUTF8Pointer = UnsafePointer<GLchar>(shaderStringUTF8)
    glShaderSource(shader, 1, &shaderStringUTF8Pointer, nil)
    glCompileShader(shader)

    var success:GLint = 0
    glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &success)
    var infoLog = [GLchar](repeating: 0, count: 512)
    if success != GLint(GL_TRUE) {
      glGetShaderInfoLog(shader, 512, nil, &infoLog)
      print("\noh no :( there was an error compiling the \(filename) \(type) shader.\n")
    }

    glAttachShader(program, shader)
    return shader
  }
}


