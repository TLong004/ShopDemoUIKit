struct Product: Codable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let rating: Double
    let images: [String]
    let thumbnail: String
}
struct ProductResponse: Codable {
    let products: [Product]
}
struct DataProduct: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}
