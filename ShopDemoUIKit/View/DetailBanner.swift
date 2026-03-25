//
//  DetailBanner.swift
//  ShopDemoUIKit
//
//  Created by gem on 20/3/26.
//

import UIKit
import Kingfisher

class DetailBanner: UICollectionViewCell {
    @IBOutlet weak var bannerImage: UIImageView!
    
    func setImage(_ imageUrl: String){
        bannerImage.setImage(imageUrl)
    }
}
