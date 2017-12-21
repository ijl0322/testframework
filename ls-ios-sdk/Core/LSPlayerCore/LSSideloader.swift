//
//  LSSideloader.swift
//  Littlstar
//
//  Created by vanessa pyne on 10/25/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices

public protocol LSSideloaderDelegate {
  func lsSideloader(didFinishGettingURL url: URL)
}

@objc open class LSSideloader: UIViewController {
  let picker = UIImagePickerController()
  var hasPresentedPicker: Bool = false

  public var delegate: LSSideloaderDelegate?
  public init() {
    super.init(nibName: nil, bundle: nil)
    self.view.backgroundColor = .clear
    self.modalPresentationStyle = .overCurrentContext
    picker.delegate = self
    picker.allowsEditing = false
    picker.sourceType = .photoLibrary
    picker.mediaTypes += [kUTTypeMovie as String]
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !hasPresentedPicker {
      hasPresentedPicker = true
      self.present(picker, animated: true, completion: nil)
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension LSSideloader: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    var mediaURL = info[UIImagePickerControllerMediaURL]
    if nil == info[UIImagePickerControllerMediaURL] {
      if #available(iOS 11.0, *) {
        mediaURL = info[UIImagePickerControllerImageURL]
      } else {
//        TODO: something here
      }
    }
    picker.dismiss(animated: true) {
      self.dismiss(animated: false, completion: nil)
      self.delegate?.lsSideloader(didFinishGettingURL: mediaURL as! URL)
    }
  }

  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.dismiss(animated: false, completion: nil)
    }
  }
}

