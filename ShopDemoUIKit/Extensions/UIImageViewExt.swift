//
//  UIImageViewExt.swift
//  ShopDemoUIKit
//
//  Created by gem on 25/3/26.
//

import Foundation
import Kingfisher

extension UIImageView {
    func setImage(_ imageUrl: String?, placeholder: String = "poster_placeholder") {
        guard let path = imageUrl, !path.isEmpty else {
            self.image = UIImage(named: placeholder)
            return
        }
        guard let url = URL(string: path) else {
            return
        }
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, placeholder: UIImage(named: placeholder), options: [
            .transition(.fade(0.3)),
            .cacheSerializer(FormatIndicatedCacheSerializer.png)
        ])
    }
}
