
import Foundation

struct UserReview: Codable {
    let productId: Int
    let rating: Int
    let content: String
    let images: [String]
    let userName: String
    let createdAt: Date
}
