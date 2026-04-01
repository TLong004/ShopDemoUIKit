
import Foundation

class ReviewManager {
    static let shared = ReviewManager()
    private init() {}
    
    func addReview(userReview: UserReview) {
        let key = "review_\(userReview.productId)"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userReview) {
            UserDefaults.standard.set(encoded, forKey: key)
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
}
