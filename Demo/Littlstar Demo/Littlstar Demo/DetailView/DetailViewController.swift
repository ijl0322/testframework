//
//  DetailViewController.swift
//  Littlstar
//
//  Created by Huy Dao on 1/30/17.
//  Copyright © 2017 Littlstar. All rights reserved.
//

import UIKit

@objc class DetailViewController: UIViewController {
  var controller: DetailController?
  var detailView: DetailView!
  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    detailView = DetailView(frame: CGRect(x: 0, y: 0,
                                          width: view.frame.width,
                                          height: view.frame.height),
                            navBarHeight: self.navigationController!.navigationBar.frame.height)
    self.view.backgroundColor = UIColor.black
    self.view.addSubview(detailView)
    controller = DetailController(detailView: detailView, controller: self)
  }


  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.setStatusBarHidden(false, with: .fade)
  }

}


