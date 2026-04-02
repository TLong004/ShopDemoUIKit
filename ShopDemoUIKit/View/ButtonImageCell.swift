//
//  ButtonImageCell.swift
//  ShopDemoUIKit
//
//  Created by gem on 2/4/26.
//

import UIKit


class ButtonImageCell: UICollectionViewCell {
    
    @IBOutlet weak var button: DesignableButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func confige(check: Bool){
        if check {
            button.setTitle("Hình ảnh/ Video/ Video theo mẫu", for: .normal)
            button.imageView?.image = UIImage(systemName: "camera")
        } else {
            button.setTitle("Tải lên", for: .normal)
            button.imageView?.image = UIImage(systemName: "camera")
        }
    }

}
