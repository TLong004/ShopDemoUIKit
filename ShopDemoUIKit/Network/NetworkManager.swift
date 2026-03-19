import Foundation

struct API {
    static let products = "https://dummyjson.com/products"
    static let category = products + "/categories"
    static let banner = products + "?limit=6"
    static let search = products + "/search?q="
}

class NetworkManager {
    static let shared = NetworkManager()
    
    func request<T: Codable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw NetworkError.requestFailed
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
