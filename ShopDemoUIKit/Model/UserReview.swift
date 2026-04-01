
import Foundation

struct UserReview: Codable {
    var productId: Int
    var rating: Int
    var content: String
    var images: [String]
    var createdAt: String
    
    init(productId: Int, rating: Int, content: String, images: [String], createdAt: String) {
        self.productId = productId
        self.rating = rating
        self.content = content
        self.images = images
        self.createdAt = createdAt
    }

}
