
import Foundation
import UIKit

class ReviewManager {
    static let shared = ReviewManager()
    private init() {}
    
    private let keyList = "saved_review_ids"
    
    var listId: [Int] {
        return UserDefaults.standard.array(forKey: keyList) as? [Int] ?? []
    }
    
    func addReview(userReview: UserReview) {
        let key = "review_\(userReview.productId)"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userReview) {
            UserDefaults.standard.set(encoded, forKey: key)
            var currentList = listId
            if !currentList.contains(userReview.productId) {
                currentList.append(userReview.productId)
                UserDefaults.standard.set(currentList, forKey: keyList)
            }
        }
    }
    
    func loadReview(forProductId productId: Int) -> UserReview? {
        let key = "review_\(productId)"
        if let savedReviewData = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let loadedReview = try? decoder.decode(UserReview.self, from: savedReviewData) {
                return loadedReview
            }
        }
        return nil
    }
    
    func saveImageToDisk(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName = "\(UUID().uuidString).jpg"
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let filePath = path[0].appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            return fileName
        } catch {
            print("Lỗi lưu ảnh")
            return nil
        }
    }
    
    func isReview(product: Product) -> Bool {
        if listId.contains(product.id) {
            return true
        }
        return false
    }
    
    func loadImageFromDisk(fileName: String) -> UIImage? {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let filePath = path[0].appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: filePath.path) {
            return UIImage(contentsOfFile: filePath.path)
        }
        return nil
    }
}
