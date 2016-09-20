//
//  FilterFlagsCollectionViewCell.swift
//  CountryTrainer
//
//  Created by Ben Sullivan on 16/09/2016.
//  Copyright © 2016 Ben Sullivan. All rights reserved.
//

import UIKit

protocol FilterFlagDelegate {
  func removeFlagButtonPressed(country: Country)
}

class FilterFlagsCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var flagImage: UIImageView!
  @IBOutlet weak var addRemoveImage: UIImageView!
  
  @IBOutlet weak var countryName: UILabel!
  @IBOutlet weak var bgView: UIView!
  
  var country: Country?
  var filterFlagDelegate: FilterFlagDelegate?
  
  override func awakeFromNib() {
    
    bgView.layer.cornerRadius = 5.0
  }
  
  @IBAction func removeButtonPressed(_ sender: UIButton) {
    
    filterFlagDelegate?.removeFlagButtonPressed(country: country!)
  }
  
  
  
  
  func configureView(country: Country, isRemainingCountry: Bool) {
    
    if flagImage.image == nil {
      //still loses a few frames on initial scroll
      let image = UIImage(named: country.flagSmall) ?? UIImage(named: country.flag)
      flagImage.image = resizeImage(image: image!, newWidth: 200)
    }
    
    addRemoveImage.image = isRemainingCountry ? #imageLiteral(resourceName: "filterFlagDeletebutton") : #imageLiteral(resourceName: "filterFlagAddButton")
    
    self.country = country
    countryName.text = country.name
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
}
