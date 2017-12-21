//
//  LSSphereGeometry.swift
//  Littlstar
//
//  Created by vanessa pyne on 9/1/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation

// thanks: https://www.nomtek.com/video-360-in-opengl-ios-part-3-sky-sphere/

class LSSphereGeometry {
  var columns: UInt32 = 64
  var rows: UInt32 = 64
  var radius: Float = 1
  var verticesAndUVs = [Float]()
  var indices = [GLuint]()

  init() {
    generateVerticesAndUVs()
    generateIndicesForTriangleStrip()
  }

  func getVerticesAndUVs() -> Array<Float> {
    return verticesAndUVs
  }

  func getIndices() -> Array<GLuint> {
    return indices
  }

  private func generateVerticesAndUVs() {
    let deltaAlpha = Float(2.0 * .pi) / Float(self.columns)
    let deltaBeta = Float(Double.pi) / Float(self.rows)
    for row in 0...self.rows {
      let beta = Float(row) * deltaBeta
      let y = self.radius * cosf(beta)
      let tv = Float(row) / Float(self.rows)
      for col in 0...self.columns {
        let alpha = Float(col) * deltaAlpha
        let x = self.radius * sinf(beta) * cosf(alpha)
        let z = self.radius * sinf(beta) * sinf(alpha)

        let tu = Float(col) / Float(self.columns)

        verticesAndUVs.append(tu)
        verticesAndUVs.append(tv)

        verticesAndUVs.append(x)
        verticesAndUVs.append(y)
        verticesAndUVs.append(z)
      }
    }
  }

  private func generateIndicesForTriangleStrip() {
    for row in 1...self.rows
    {
      let topRow = row - 1
      let topIndex = (self.columns + 1) * topRow
      let bottomIndex = topIndex + (self.columns + 1)
      for col in 0...self.columns {
        indices.append(GLuint(topIndex + col))
        indices.append(GLuint(bottomIndex + col))
      }

      indices.append(GLuint(topIndex))
      indices.append(GLuint(bottomIndex))
    }
  }
}
