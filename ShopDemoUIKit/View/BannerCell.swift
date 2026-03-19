//
//  BannerCell.swift
//  ShopDemoUIKit
//
//  Created by gem on 19/3/26.
//

import UIKit

class BannerCell: UICollectionViewCell {
    @IBOutlet weak var bannerImage: UIImageView!
    
    func setImage(_ imageUrl: String){
        let cacheKey = NSString(string: imageUrl)
        
        if let imageCache = ImageCache.shared.object(forKey: cacheKey) {
            print("Đã lấy ảnh từ cache")
            self.bannerImage.image = imageCache
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
                self.bannerImage.image = image
            } catch {
                print("Lỗi tải ảnh")
            }
        }
    }
}
