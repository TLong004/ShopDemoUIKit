//
//  DetailImageProductCell.swift
//  ShopDemoUIKit
//
//  Created by gem on 20/3/26.
//

import UIKit
protocol tapImageProductDelegate: AnyObject {
    func didSelectImage(image: String)
}
class DetailImageProductCell: UICollectionViewCell {
    @IBOutlet weak var detailImage: UIImageView!
    weak var delegate: tapImageProductDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.detailImage.addGestureRecognizer(tapGesture)
        self.detailImage.isUserInteractionEnabled = true
    }
    
    var imageUrl: String!
    
    func setImage(_ imageUrl: String){
        self.imageUrl = imageUrl
        let cacheKey = NSString(string: imageUrl)
        
        if let imageCache = ImageCache.shared.object(forKey: cacheKey) {
            print("Đã lấy ảnh từ cache")
            self.detailImage.image = imageCache
            return
        }
        Task {
            guard let url = URL(string: imageUrl) else {
                return
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    return
                }
                ImageCache.shared.setObject(image, forKey: cacheKey)
                print("Đã lưu ảnh vào cache")
                self.detailImage.image = image
            } catch {
                print("Lỗi tải ảnh")
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            detailImage.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
            detailImage.backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.1) : .systemGray6
        }
    }
    
    @objc func handleTapGesture() {
        delegate?.didSelectImage(image: imageUrl)
    }
}
