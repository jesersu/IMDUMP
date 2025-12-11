import Foundation
import Alamofire
import ArkanaKeys

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

    // Convert to Alamofire HTTPMethod
    var alamofireMethod: Alamofire.HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        }
    }
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

// MARK: - Network Service Implementation with Alamofire
// SOLID: Ready to use SecretsManager for encrypted API keys
class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()

    private let baseURL: String
    private let apiKey: String
    private let session: Session

    init(baseURL: String? = nil, apiKey: String? = nil) {
        // Using Arkana for encrypted secrets
        let arkana = ArkanaKeys.Global()
        self.baseURL = baseURL ?? arkana.aPIBaseURL
        self.apiKey = apiKey ?? arkana.tMDBAPIKey

        // Configure Alamofire session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = Session(configuration: configuration)
    }

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = baseURL + endpoint

        // Prepare parameters with API key
        var allParameters = parameters ?? [:]
        allParameters["api_key"] = apiKey

        // Make request using Alamofire
        session.request(
            url,
            method: method.alamofireMethod,
            parameters: allParameters,
            encoding: URLEncoding.default
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))

            case .failure(let error):
                // Handle different types of errors
                if let statusCode = response.response?.statusCode {
                    completion(.failure(NetworkError.serverError(statusCode)))
                } else if error.isResponseSerializationError {
                    print("Decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError))
                } else if error.isSessionTaskError {
                    completion(.failure(error))
                } else {
                    completion(.failure(NetworkError.unknown))
                }
            }
        }
    }
}
