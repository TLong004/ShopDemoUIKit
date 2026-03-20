//
//  CategoryCell.swift
//  ShopDemoUIKit
//
//  Created by gem on 19/3/26.
//

import UIKit

protocol CategoryCellDelegate: AnyObject {
    func didTapCategoryCell(_ category: String)
}

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: CategoryCellDelegate?
    var category: String = ""
    
    func setButtonTitle(_ title: String, slug: String) {
        button.setTitle(title, for: .normal)
        category = slug
    }
    
    @IBAction func didTapCell(_ sender: UIButton) {
        delegate?.didTapCategoryCell(category)
    }
    override var isSelected: Bool {
        didSet{
            button.backgroundColor = isSelected ? .systemBlue : .systemGray6
            button.setTitleColor(isSelected ? .white : .black, for: .normal)
        }
    }
}
