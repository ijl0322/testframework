//
//  TestView.swift
//  Littlstar Demo
//
//  Created by vanessa pyne on 11/14/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

import UIKit

protocol TestViewDelegate {
  func testviewAbout()
  func testViewStream(media: URL)
  func testViewSideload()
}

class TestView: UIView {
  var delegate: TestViewDelegate?
  var starBranding: UIView!
  var mainScroll: UITableView!
  var blurView: UIVisualEffectView!
  var headerHeight: CGFloat!
  let margin: CGFloat = 16
  var shouldDisplay = false
  var brandImage: UIImageView!

  // invasion // discovery sharks // asteriods //
  var videos = [
    "https://360.littlstar.com/production/0572c041-bfb2-4476-b376-5f09c8e5f10b/mobile_hls.m3u8",
    "https://360.littlstar.com/production/76b490a5-2125-4281-b52d-8198ab0e817d/mobile_hls.m3u8",
    "https://360.littlstar.com/production/c470938e-0665-4431-9927-4ccf358fe127/mobile_hls.m3u8"
  ]
  var banners = [
    "https://ls-prod-media.s3.amazonaws.com/banners/f079c8bad5c48576a23d38af94360d580b880c35.jpg?1507919150",
    "https://ls-360-media.s3.amazonaws.com/production/0572c041-bfb2-4476-b376-5f09c8e5f10b/banner-medium.jpg",
    "https://ls-360-media.s3.amazonaws.com/production/c470938e-0665-4431-9927-4ccf358fe127/poster-medium.png"
  ]

  func switchDisplay() {
    shouldDisplay = true
    displayHome()
  }

  func displayHome() {
    if shouldDisplay {
      mainScroll.reloadData()
      brandImage.alpha = 0
      UIView.animate(withDuration: 0.3, animations: {
        self.mainScroll.alpha = 1
      })
    }
  }

  init(frame: CGRect, navBarHeight: CGFloat) {
    super.init(frame: frame)
    self.headerHeight = navBarHeight + 20

    // Background
    let backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_placeholder.png"))
    backgroundView.contentMode = .scaleAspectFill
    backgroundView.frame = frame
    self.addSubview(backgroundView)

    let displayTimer = Timer(timeInterval: 1.5, target: self, selector: #selector(switchDisplay), userInfo: nil, repeats: false)
    RunLoop.main.add(displayTimer, forMode: .commonModes)

    //Syfy brand
    brandImage = UIImageView(image: #imageLiteral(resourceName: "background_placeholder.png").withRenderingMode(.alwaysTemplate))
    brandImage.tintColor = UIColor(red: 196/255, green: 112/255, blue: 219/255, alpha: 1)
    brandImage.center = self.center
    self.addSubview(brandImage)

    // Show Table
    mainScroll = UITableView(frame: self.frame, style: .grouped)
    mainScroll.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    mainScroll.backgroundColor = UIColor.clear
    mainScroll.separatorStyle = .none
    mainScroll.rowHeight = (((UIApplication.shared.delegate as! AppDelegate).window!.frame.width - (margin * 2))/1.78) + margin
    mainScroll.alpha = 0

    mainScroll.delegate = self
    mainScroll.dataSource = self
    self.addSubview(mainScroll)

    // Littlstar Brand
    let starBrandingHeight: CGFloat = 250
    starBranding = UIView(frame: CGRect(x: 0, y: (UIApplication.shared.delegate as! AppDelegate).window!.frame.height - starBrandingHeight, width: (UIApplication.shared.delegate as! AppDelegate).window!.frame.width, height: starBrandingHeight))
    starBranding.isUserInteractionEnabled = false
    self.addSubview(starBranding)

    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.9).cgColor]
    gradient.startPoint = CGPoint(x: 0, y: 0)
    gradient.endPoint = CGPoint(x: 0, y: 1)
    gradient.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.delegate as! AppDelegate).window!.frame.width, height: starBrandingHeight)
    starBranding.layer.addSublayer(gradient)

    let iconBufferHeight: CGFloat = 20
    let lsIcon = UIImageView(image: #imageLiteral(resourceName: "littlstar_24dp.png"))
    lsIcon.frame.origin.y = starBrandingHeight - lsIcon.frame.height - iconBufferHeight
    lsIcon.center.x = ((UIApplication.shared.delegate as! AppDelegate).window!.frame.width)/2
    starBranding.addSubview(lsIcon)

    let powerText = UILabel()
    powerText.text = "powered by"
    powerText.textColor = UIColor.white
    powerText.sizeToFit()
    powerText.frame.origin.y = lsIcon.frame.minY - powerText.frame.height - 10
    powerText.center.x = ((UIApplication.shared.delegate as! AppDelegate).window!.frame.width)/2
    starBranding.addSubview(powerText)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func buttonSelected(button: UIButton) {
    delegate?.testviewAbout()
  }
}

extension TestView: UITableViewDataSource, UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Display starBrand when the scroll is at the top
    if scrollView.contentOffset.y <= -20 {
      UIView.animate(withDuration: 0.2) {
        self.starBranding.alpha = 1
      }
    } else {
      // Otherwise Hide starBrand
      if self.starBranding.alpha != 0 {
        UIView.animate(withDuration: 0.2) {
          self.starBranding.alpha = 0
        }
      }
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videos.count + 1
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return headerHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    // Brand panel
    let brandPanel = UIView(frame: CGRect(x: 0, y: 0, width: (UIApplication.shared.delegate as! AppDelegate).window!.frame.width, height: headerHeight))

    // Brand Logo
    // let image = Bundle.main.path(forResource: "sideload_placeholder", ofType: "png")
    //   let i = UIImage(contentsOfFile: image!)
    //   let resizedImage = i?.resizeImageWith(newSize: showImage.frame.size)
    // let brandLogo = UIImageView(image: #imageLiteral(resourceName: "bigLogo.png"))
    let brandLogo = UIImageView(image: #imageLiteral(resourceName: "demo_app.png"))
    brandLogo.frame.origin.x = margin
    brandLogo.center.y = headerHeight/2
    brandPanel.addSubview(brandLogo)

    // Divider
    let divider = UIView(frame: CGRect(x: brandLogo.frame.maxX + margin, y: headerHeight/4, width: 1, height: headerHeight/2))
    divider.backgroundColor = UIColor.white
    brandPanel.addSubview(divider)

    // Additional Text
    let additionalText = UILabel(frame: CGRect(x: divider.frame.maxX + margin,
                                               y: 0,
                                               width: 100,
                                               height: headerHeight))
    additionalText.textAlignment = .left
    additionalText.textColor = UIColor.white
    additionalText.text = "360 player"
    brandPanel.addSubview(additionalText)

    // About
    let aboutButton = UIButton(type: .custom)
    aboutButton.setImage( #imageLiteral(resourceName: "cloud_24dp").withRenderingMode(.alwaysTemplate), for: .normal)
    aboutButton.tintColor = UIColor(red: 96/255, green: 212/255, blue: 219/255, alpha: 1)
    aboutButton.frame.size = CGSize(width: 16, height: 16)
    aboutButton.frame.origin.x = (UIApplication.shared.delegate as! AppDelegate).window!.frame.width - margin - aboutButton.frame.width
    aboutButton.center.y = headerHeight/2
    aboutButton.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
    brandPanel.addSubview(aboutButton)

    return brandPanel
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.backgroundColor = UIColor.clear
    cell.selectionStyle = .none

    var showImage = cell.contentView.viewWithTag(1) as? UIImageView
    if showImage == nil {
      let imageWidth = (UIApplication.shared.delegate as! AppDelegate).window!.frame.width - (margin * 2)
      showImage = UIImageView(frame: CGRect(x: margin, y: 0, width: imageWidth, height: imageWidth/1.78))
      showImage?.contentMode = .bottomLeft
      showImage?.clipsToBounds = true
      showImage?.tag = 1
      showImage?.backgroundColor = UIColor.brown
      cell.contentView.addSubview(showImage!)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let showImage = cell.viewWithTag(1) as! UIImageView

    if ( (videos.count) == indexPath[1] ) {
      let image = Bundle.main.path(forResource: "sideload_placeholder", ofType: "png")
      let i = UIImage(contentsOfFile: image!)
      let resizedImage = i?.resizeImageWith(newSize: showImage.frame.size)
      showImage.image = resizedImage
    } else {
      let url = URL(string: banners[indexPath[1]])
      DispatchQueue.global().async {
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        DispatchQueue.main.async {
          let i = UIImage(data: data!)
          let resizedImage = i?.resizeImageWith(newSize: showImage.frame.size)
          showImage.image = resizedImage
        }
      }
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if ( (videos.count) == indexPath[1] ) {
      tableView.cellForRow(at: indexPath)?.alpha = 0.77
      UIView.animate(withDuration: 0.3, animations: {
        void in
        tableView.cellForRow(at: indexPath)?.alpha = 1.0
      })
      delegate?.testViewSideload()
    } else {
      let media = videos[indexPath[1]]
      delegate?.testViewStream(media: URL(string: media)! )
    }
  }
}
