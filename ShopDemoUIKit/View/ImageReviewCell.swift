//
//  ImageReviewCell.swift
//  ShopDemoUIKit
//
//  Created by gem on 2/4/26.
//

import UIKit

protocol ImageReviewCellDelegate: AnyObject {
    func didDeleteImage(cell: ImageReviewCell)
}

class ImageReviewCell: UICollectionViewCell {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var imageReview: UIImageView!
    weak var delegate: ImageReviewCellDelegate?
    @IBAction func deleteImage(_ sender: Any) {
        delegate?.didDeleteImage(cell: self)
    }
    func setImage(_ image: UIImage){
        imageReview.image = image
    }
    
}
