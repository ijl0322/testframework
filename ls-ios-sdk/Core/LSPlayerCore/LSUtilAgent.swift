//
//  LSUtilAgent.swift
//  Littlstar
//
//  Created by vanessa pyne on 9/14/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation

// https://stackoverflow.com/a/40262254/3191800
func ls_bufferOffset(_ i: Int) -> UnsafeRawPointer? {
  return UnsafeRawPointer(bitPattern: i)
}

// https://stackoverflow.com/a/40868784/3191800
extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}

// https://github.com/raywenderlich/swift-algorithm-club/tree/master/Ring%20Buffer
public struct RingBuffer<T> {
  fileprivate var array: [T?]
  fileprivate var readIndex = 0
  fileprivate var writeIndex = 0

  public init(count: Int) {
    array = [T?](repeating: nil, count: count)
  }

  public mutating func write(_ element: T) -> Bool {
    // if thread safety becomes a concern OSAtomicIncrement64 might be a solution
    // OSAtomicIncrement64(<#UnsafeMutablePointer<OSAtomic_int64_aligned64_t>!#>)
    if !isFull {
      array[writeIndex % array.count] = element
      writeIndex += 1
      return true
    } else {
      return false
    }
  }

  public mutating func read() -> T? {
    let readValue = self.peek()
    if nil != readValue {
      readIndex += 1
    }
    return readValue
  }

  public mutating func peek() -> T? {
    if !isEmpty {
      let element = array[readIndex % array.count]
      return element
    } else {
      return nil
    }
  }

  fileprivate var availableSpaceForReading: Int {
    return writeIndex - readIndex
  }

  public var isEmpty: Bool {
    return availableSpaceForReading == 0
  }

  fileprivate var availableSpaceForWriting: Int {
    return array.count - availableSpaceForReading
  }

  public var isFull: Bool {
    return availableSpaceForWriting == 0
  }

  public func map() {
    array.map {
      if nil != $0 {
        print($0!, " ", terminator:"")
      }
    }
  }
}

// https://stackoverflow.com/a/42546027/3191800
extension UIImage{
  public func resizeImageWith(newSize: CGSize) -> UIImage {
    let horizontalRatio = newSize.width / size.width
    let verticalRatio = newSize.height / size.height

    let ratio = max(horizontalRatio, verticalRatio)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
    draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }
}