import Foundation

// MARK: - Network Service Protocol
// SOLID: Interface Segregation Principle - Clean interface for network operations
protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case serverError(Int)
    case unknown

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Network Service Implementation
// This will be replaced with Alamofire implementation
// SOLID: Ready to use SecretsManager for encrypted API keys
class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()

    private let baseURL: String
    private let apiKey: String

    init(baseURL: String? = nil, apiKey: String? = nil) {
        // When SecretsManager is added to Xcode project, use:
        // self.baseURL = baseURL ?? SecretsManager.shared.apiBaseURL
        // self.apiKey = apiKey ?? SecretsManager.shared.tmdbAPIKey

        self.baseURL = baseURL ?? "https://api.themoviedb.org/3"
        self.apiKey = apiKey ?? ProcessInfo.processInfo.environment["TMDB_API_KEY"] ?? "YOUR_API_KEY_HERE"
    }

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        // Add API key and other parameters
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let parameters = parameters {
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }

        task.resume()
    }
}
