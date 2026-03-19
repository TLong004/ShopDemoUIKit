import UIKit
class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    private init() {
        ImageCache.shared.countLimit = 100
        ImageCache.shared.totalCostLimit = 50*1024*1024
    }
}
