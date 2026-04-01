//
//  DetailProduct.swift
//  ShopDemoUIKit
//
//  Created by gem on 20/3/26.
//

import UIKit

class DetailProduct: UICollectionViewCell {
    
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var name: UILabel!

    func config(product: Product){
        name.text = product.title
        price.text = "$\(product.price)"
        rating.text = "⭐️\(product.rating)"
        desc.text = product.description
    }
}
