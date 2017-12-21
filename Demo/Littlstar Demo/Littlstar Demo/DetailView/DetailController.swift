//
//  DetailController.swift
//  Littlstar0
//
//  Created by Huy Dao on 1/30/17.
//  Copyright © 2017 Littlstar. All rights reserved.
//

import UIKit
import ls_ios_sdk

class DetailModel {
  var trailerList: [LSVideoItem] = []
  var feedLoadCount = 0

  init() {
    let videoA = LSVideoItem()
    videoA.bannerImage = #imageLiteral(resourceName: "AImage")
    videoA.title = "INVASION!"
    videoA.desc = "From the director of Madagascar and narrated by Ethan Hawke, INVASION! is an award-winning VR animation about a duo of aliens with grand ambitions to take over our world. Instead, they are greeted by two adorable, white bunnies….and YOU are one of them! Official selection of Cannes Le Marché du Film, Toronto International Film Festival, and Tribeca Film Festival."
    videoA.duration = 129
    videoA.videoURL = URL(string: "https://360.littlstar.com/production/76b490a5-2125-4281-b52d-8198ab0e817d/mobile_hls.m3u8")!
    trailerList.append(videoA)

    let videoB = LSVideoItem()
    videoB.bannerImage = #imageLiteral(resourceName: "BImage")
    videoB.title = "Save Every Breath: The Dunkirk VR Experience"
    videoB.desc = "Save Every Breath: The Dunkirk VR Experience will propel viewers into the action on land, sea and air. The pulse-pounding 360-degree short film immerses the viewer in the world of Christopher Nolan’s epic action thriller “Dunkirk.” Through three tightly woven sequences, the virtual reality experience offers a tantalizing taste of the much-anticipated film, in which 400,000 Allied soldiers are trapped on the beach of Dunkirk, France, with their backs to the sea as the enemy closes in. “Dunkirk” opens in conventional theatres and IMAX on July 21, 2017. (alt to last line.) “Dunkirk” opens in theatres and IMAX on July 21, 2017."
    videoB.duration = 276
    videoB.videoURL = URL(string: "https://360.littlstar.com/production/f9ac8af0-1bee-4472-a8fc-09c4b7b9086f/mobile_hls.m3u8")!
    trailerList.append(videoB)

    let videoC = LSVideoItem()
    videoC.bannerImage = #imageLiteral(resourceName: "CImage")
    videoC.title = "Kids"
    videoC.desc = "The official music video experience for OneRepublic’s new single “Kids”, filmed in Mexico City with Nokia OZO: http://ozo.nokia.com. This VR experience was captured in a single take and relied on the precise choreography of over 100 people. Learn more at www.onerepublic.com."
    videoC.duration = 129
    videoC.videoURL = URL(string: "https://360.littlstar.com/production/ecb456eb-9bf2-47ce-a41d-97cc58ca216a/mobile_hls.m3u8")!
    trailerList.append(videoC)

    let videoD = LSVideoItem()
    videoD.bannerImage = #imageLiteral(resourceName: "DImage")
    videoD.title = ""
    videoD.desc = ""
    videoD.duration = 0
    videoD.videoURL = URL(string: "sideload")!
    trailerList.append(videoD)
  }
}

class DetailController: NSObject {
  weak var detailView: DetailView?
  var detailModel = DetailModel()
  var navController: UINavigationController
  var controller: UIViewController
  
  init(detailView: DetailView, controller: DetailViewController) {
    self.detailView = detailView
    self.controller = controller
    self.navController = controller.navigationController!
    super.init()
    self.detailView?.delegate = self

    detailView.mainScroll.reloadData()
  }
}

extension DetailController: DetailViewDelegate, LSSideloaderDelegate{
  func detailviewGetItemsCount() -> Int {
    return detailModel.trailerList.count
  }
  
  
  func detailviewClose() {
    navController.popViewController(animated: true)
  }
  
  func detailview(getLSItem index: IndexPath) -> LSVideoItem {
    return detailModel.trailerList[index.row]
  }
  
  func detailview(selectRow index: IndexPath) {
    var url = detailModel.trailerList[index.row].videoURL
    if url?.absoluteString == "sideload" {
      let sideloadView = LSSideloader()
      sideloadView.delegate = self
      controller.present(sideloadView, animated: false, completion: nil)
    } else {
      //    TODO: - Uncomment to test photo, remove when done
//      let photoURL = Bundle.main.path(forResource: "govball", ofType: "jpg")
//      url = URL(fileURLWithPath: photoURL!)
      //let vc = ViewController(url: url!)
        let vc = ObjectiveCViewController()
      navController.pushViewController(vc, animated: true)
    }
  }

  func lsSideloader(didFinishGettingURL url: URL) {
    let vc = ViewController(url: url)
    navController.pushViewController(vc, animated: true)
  }

}
