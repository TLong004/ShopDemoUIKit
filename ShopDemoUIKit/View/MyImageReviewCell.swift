//
//  ImageReviewCell.swift
//  ShopDemoUIKit
//
//  Created by gem on 2/4/26.
//

import UIKit


class MyImageReviewCell: UICollectionViewCell {

    @IBOutlet weak var myImageReview: UIImageView!

    func setImage(_ image: UIImage){
        myImageReview.image = image
    }
    
}
