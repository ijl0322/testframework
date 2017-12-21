//
//  DetailView.swift
//  Littlstar
//
//  Created by Huy Dao on 1/30/17.
//  Copyright © 2017 Littlstar. All rights reserved.

import UIKit

@objc protocol DetailViewDelegate {
  func detailviewGetItemsCount() -> Int
  func detailview(getLSItem index: IndexPath) -> LSVideoItem
  func detailview(selectRow index: IndexPath)
  func detailviewClose()
}

class DetailView: UIView {
  var blurView: UIVisualEffectView!
  var delegate: DetailViewDelegate?
  var brandPanel: UIView!
  var mainScroll: UITableView!
  var backgroundImage: UIImageView!
  var logoImage: UIImageView!
  let margin: CGFloat = 16
  let posterHeight: CGFloat
  var panelHeight: CGFloat = 0
  var masthead: UIImageView!
  var selectRow: Int?
//  var loadingIndicator: LSActivityIndicator!
  var extraXHeight: CGFloat {
//    return UIDevice.current.detectDevice() == .iphoneX ? frame.statusBarHeight : 0
    return 0
  }

  enum cellTag: Int {
    case poster = 1
    case play
    case watch
    case details
    case divider
    case title
    case runtime
    case description
  }
  
  func close() {
    delegate?.detailviewClose()
  }
  
  init(frame: CGRect, navBarHeight: CGFloat) {
    posterHeight = frame.width/1.78
    super.init(frame: frame)
    let navBarHeight = navBarHeight + 20
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    panelHeight = statusBarHeight + navBarHeight
    
    // Masthead
    masthead = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: posterHeight))
    masthead.image = #imageLiteral(resourceName: "masthead")
    masthead.contentMode = .scaleAspectFill
    masthead.clipsToBounds = true

    self.addSubview(masthead)
    
    // Blur view
    blurView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: frame.width, height: posterHeight))
    blurView.effect = UIBlurEffect(style: .dark)
    blurView.alpha = 0
    masthead.addSubview(blurView)
    
    // Background image
    backgroundImage = UIImageView(frame: CGRect(x: 0, y: masthead.frame.maxY, width: frame.width  , height: frame.height))
    backgroundImage.contentMode = .scaleAspectFill
    backgroundImage.clipsToBounds = true
    backgroundImage.image = #imageLiteral(resourceName: "background.png")
    self.addSubview(backgroundImage)
    
    // Light Shadow
    let shadow = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
    shadow.backgroundColor = UIColor(white: 0, alpha: 0.1)
    backgroundImage.addSubview(shadow)
    
    // Show Table

    mainScroll = UITableView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 50))
    mainScroll.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    mainScroll.separatorStyle = .none
    mainScroll.backgroundColor = UIColor.clear
    mainScroll.contentInset = UIEdgeInsets(top: posterHeight, left: 0, bottom: 0, right: 0)
    mainScroll.delegate = self
    mainScroll.dataSource = self
    self.addSubview(mainScroll)

    let brandView = UIImageView(image: #imageLiteral(resourceName: "brand"))
    brandView.frame.size = CGSize(width: 230, height: 50)
    brandView.contentMode = .scaleAspectFit
    brandView.frame.origin = CGPoint(x: frame.width - 248, y: frame.height - 50)
    self.addSubview(brandView)
    
    
//    // Loading Icon
//    loadingIndicator = LSActivityIndicator.small(withPosition: mainScroll.center.x, y: (frame.screenHeight - posterHeight)/2, color: UIColor.white)
//    loadingIndicator.startAnimating()
//    mainScroll.addSubview(loadingIndicator)

    // Brand panel
    brandPanel = UIView(frame: CGRect(x: 0, y: 0,
                                      width: frame.width,
                                      height: panelHeight))
    self.addSubview(brandPanel)
    
    // Brand Icon
    let brand = UIImageView(image: #imageLiteral(resourceName: "littlstar_logo"))
    brand.frame.size = CGSize(width: 50, height: 50)
    brand.contentMode = .scaleAspectFit
    brand.layer.cornerRadius = 8
    brand.isUserInteractionEnabled = true
    brand.frame.origin.x = 12
    brand.center.y = statusBarHeight + navBarHeight/2
    brand.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    brand.clipsToBounds = true
    brandPanel.addSubview(brand)

    let lsText = UILabel(frame: CGRect(x: brand.frame.maxX + 12, y: brand.frame.minY, width: 200, height: panelHeight))
    lsText.text = "EXPERIENCE"
    lsText.textColor = .white
    lsText.font = UIFont.boldSystemFont(ofSize: 16)
    lsText.sizeToFit()
    brandPanel.addSubview(lsText)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension DetailView: UITableViewDataSource, UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.y + posterHeight
    let scrollPercentage = -scrollView.contentOffset.y/posterHeight
  
    // Table offset is at or below posterHeight
    if offset <= 0 {
      backgroundImage.frame.origin.y = posterHeight + extraXHeight
      brandPanel.frame.origin.y = 0
      masthead.frame.origin.y = extraXHeight
      blurView.alpha = 0
    } else if offset <= (posterHeight - extraXHeight) {
      // Table offset is between above posterHeight and below topScreen
      backgroundImage.frame.origin.y = -scrollView.contentOffset.y
      brandPanel.frame.origin.y = scrollPercentage * panelHeight - panelHeight
      masthead.frame.origin.y = -offset/3 + extraXHeight
      blurView.alpha = 1 - scrollPercentage
    } else if offset > posterHeight {
      // Table offset is off screen
      backgroundImage.frame.origin.y = 0
      blurView.alpha = 0
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if delegate == nil {
      return 0
    } else {
      return delegate!.detailviewGetItemsCount()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let lsItem = delegate?.detailview(getLSItem: indexPath)
    
    var titleComparision: UILabel? = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - (margin * 2) - 90, height: 0))
//    titleComparision?.font = UIFont.assignBoldFont(frame().generalFontS)
    titleComparision?.numberOfLines = 0
    titleComparision?.text = lsItem?.title.trimmingCharacters(in: .whitespacesAndNewlines)
    titleComparision?.sizeToFit()
    
    var descriptionComparision: UILabel? = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - (margin * 2), height: 0))
//    descriptionComparision!.font =  UIFont.assignRegFont(frame().generalFontS)
    descriptionComparision!.numberOfLines = 0
    descriptionComparision!.text = lsItem!.desc.trimmingCharacters(in: .whitespacesAndNewlines)
    descriptionComparision!.sizeToFit()
    
    let posterSize: CGFloat = ((frame.width - (margin * 2))/1.78) + margin
    let controlSize: CGFloat = 60
    let detailSize: CGFloat = titleComparision!.frame.height + descriptionComparision!.frame.height + margin * 2
    titleComparision = nil
    descriptionComparision = nil
    let smallHeight = posterSize + controlSize
    let expandedHeight = smallHeight + detailSize
    if selectRow != nil {
      if indexPath.row == selectRow! {
        return expandedHeight
      } else {
        return smallHeight
      }
    } else {
      return smallHeight
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.backgroundColor = UIColor.clear
    cell.selectionStyle = .none
    cell.clipsToBounds = true
    
    let imageWidth = frame.width - (margin * 2)
    
    var divider = cell.contentView.viewWithTag(cellTag.divider.rawValue)
    if divider == nil {
      divider = UIView(frame: CGRect(x: margin, y: 0, width: imageWidth, height: 1))
      divider?.backgroundColor = UIColor(white: 1, alpha: 0.5)
      divider?.tag = cellTag.divider.rawValue
      cell.contentView.addSubview(divider!)
    }
    
    var showImage = cell.contentView.viewWithTag(cellTag.poster.rawValue) as? UIImageView
    if showImage == nil {
      showImage = UIImageView(frame: CGRect(x: margin, y: margin, width: imageWidth, height: imageWidth/1.78))
      showImage?.contentMode = .scaleAspectFill
      showImage?.alpha = 0.8
      showImage?.clipsToBounds = true
      showImage?.tag = cellTag.poster.rawValue
      cell.contentView.addSubview(showImage!)
    }
    
    var playImage = cell.contentView.viewWithTag(cellTag.play.rawValue) as? UIImageView
    if playImage == nil {
      playImage = UIImageView(frame: CGRect(x: margin, y: showImage!.frame.maxY + 18, width: 24, height: 24))
      playImage?.image = #imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate)
      playImage?.tintColor = UIColor.black
      playImage?.contentMode = .scaleAspectFill
      playImage?.clipsToBounds = true
      playImage?.tag = cellTag.play.rawValue
      cell.contentView.addSubview(playImage!)
    }
    
    var watchLabel = cell.contentView.viewWithTag(cellTag.watch.rawValue) as? UILabel
    if watchLabel == nil {
      watchLabel = UILabel (frame: CGRect(x: playImage!.frame.maxX + margin, y: showImage!.frame.maxY, width: 100, height: 60))
      watchLabel?.text = "Watch Now"
//      watchLabel?.font = UIFont.assignRegFont(frame().generalFontS)
      watchLabel?.textColor = .black
      watchLabel?.tag = cellTag.watch.rawValue
      cell.contentView.addSubview(watchLabel!)
    }
    
    var detail = cell.contentView.viewWithTag(cellTag.details.rawValue) as? LSLabel
    if detail == nil {
      detail = LSLabel(frame: CGRect(x: showImage!.frame.maxX - 100, y: 0, width: 100, height: 50))
      detail?.isUserInteractionEnabled = true
      detail?.text = "\u{FF0B}  Details"
      detail?.textColor = .black
      detail?.textAlignment = .right
//      detail?.font = UIFont.assignRegFont(frame().generalFontS)
      detail?.center.y = watchLabel!.center.y
      detail?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleCellExpansion(gesture:))))
      detail?.tag = cellTag.details.rawValue
      cell.contentView.addSubview(detail!)
    }
    detail?.userTag = indexPath.row
    
    var runtime = cell.contentView.viewWithTag(cellTag.runtime.rawValue) as? UILabel
    if runtime == nil {
      runtime = UILabel()
      runtime?.text = "Runtime 00:00"
//      runtime?.font = UIFont.assignRegFont(frame().smallFontS)
      runtime?.textColor = .darkGray
      runtime?.textAlignment = .right
      runtime?.frame = CGRect(x: showImage!.frame.maxX - 90,
                              y: watchLabel!.frame.maxY + 2, width: 90, height: 50)
      runtime?.sizeToFit()
      runtime?.tag = cellTag.runtime.rawValue
      runtime?.alpha = 0
      cell.contentView.addSubview(runtime!)
    }
    
    var titleLabel = cell.contentView.viewWithTag(cellTag.title.rawValue) as? UILabel
    if titleLabel == nil {
      titleLabel = UILabel(frame: CGRect(x: margin, y: watchLabel!.frame.maxY, width: imageWidth - runtime!.frame.width - margin, height: 0))
      titleLabel?.numberOfLines = 0
//      titleLabel?.font = UIFont.assignBoldFont(frame().generalFontS)
      titleLabel?.textColor = .black
      titleLabel?.tag = cellTag.title.rawValue
      cell.contentView.addSubview(titleLabel!)
    }
    
    var description = cell.contentView.viewWithTag(cellTag.description.rawValue) as? UILabel
    if description == nil {
      description = UILabel(frame: CGRect(x: margin, y: 0, width: imageWidth, height: 0))
      description?.alpha = 0.65
      description?.numberOfLines = 0
//      description?.font = UIFont.assignRegFont(frame().generalFontS)
      description?.textColor = .black
      description?.tag = cellTag.description.rawValue
      cell.contentView.addSubview(description!)
    }
    
    return cell
  }
  
  func toggleCellExpansion(gesture: UIGestureRecognizer){
    let button = gesture.view as! LSLabel
    let index = IndexPath(row: button.userTag, section: 0)
    
    if selectRow == button.userTag {
      selectRow = nil
      self.mainScroll.reloadRows(at: [index as IndexPath], with: .none)
    } else if selectRow != nil {
      let previousIndex = IndexPath(row: selectRow!, section: 0)
      let index = IndexPath(row: button.userTag, section: 0)
      selectRow = button.userTag
      self.mainScroll.reloadRows(at: [previousIndex, index], with: .none)
    } else {
      selectRow = button.userTag
      self.mainScroll.reloadRows(at: [index as IndexPath], with: .none)
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let lsItem = delegate?.detailview(getLSItem: indexPath)
    let title = cell.viewWithTag(cellTag.title.rawValue) as! UILabel
    let showImage = cell.viewWithTag(cellTag.poster.rawValue) as! UIImageView
    let description = cell.viewWithTag(cellTag.description.rawValue) as! UILabel
    let divider = cell.viewWithTag(cellTag.divider.rawValue)
    let runtime = cell.viewWithTag(cellTag.runtime.rawValue) as! UILabel
    let details = cell.viewWithTag(cellTag.details.rawValue) as! UILabel
    let watchLabel = cell.viewWithTag(cellTag.watch.rawValue) as! UILabel

    showImage.image = lsItem?.bannerImage

    if indexPath.row == 3 {
      details.text = ""
      watchLabel.text = "Sideload"
    } else {
      watchLabel.text = "Watch Now"
      let minutes = (lsItem!.duration / 60) % 60
      let seconds = lsItem!.duration % 60
      runtime.text = String(format: "Runtime %d:%02d", minutes, seconds)

      if indexPath.row == selectRow {
        details.text = "\u{FF0D}  Details"
      } else {
        details.text = "\u{FF0B}  Details"
      }

      title.frame.size = CGSize(width: frame.width - (margin * 2) - 90, height: 0)
      title.text = lsItem!.title
      title.sizeToFit()

      description.frame.size = CGSize(width: frame.width - (margin * 2), height: CGFloat(0))
      description.frame.origin.y = title.frame.maxY + 8
      description.text = lsItem!.desc.trimmingCharacters(in: .whitespacesAndNewlines)
      description.sizeToFit()

      if indexPath.row == 0 {
        divider?.alpha = 0
      } else {
        divider?.alpha = 1
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Hide status bar, separate from navbarHidden to avoid animation overlap
    delegate?.detailview(selectRow: indexPath)
    UIApplication.shared.setStatusBarHidden(true, with: .fade)
  }
  
}
