import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem]?
    
    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case unauthorized
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized access"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?) async throws -> T
    func request(_ endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?) async throws
    func upload(_ data: Data, to endpoint: APIEndpoint, mimeType: String) async throws -> URL
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let configService: ConfigServiceProtocol
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    init(
        session: URLSession = .shared,
        configService: ConfigServiceProtocol = ConfigService(),
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.configService = configService
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        
        // Configure JSON coding
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        self.jsonEncoder.dateEncodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        let request = try createRequest(for: endpoint, method: method, body: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func request(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws {
        let request = try createRequest(for: endpoint, method: method, body: body)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
    
    func upload(
        _ data: Data,
        to endpoint: APIEndpoint,
        mimeType: String
    ) async throws -> URL {
        var request = try createRequest(for: endpoint, method: .post)
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (responseData, response) = try await session.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        struct UploadResponse: Codable {
            let url: URL
        }
        
        let uploadResponse = try jsonDecoder.decode(UploadResponse.self, from: responseData)
        return uploadResponse.url
    }
    
    private func createRequest(
        for endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable? = nil
    ) throws -> URLRequest {
        var components = URLComponents()
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization if needed
        if let token = try? configService.getAPIKey(for: .openAI) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try jsonEncoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        return request
    }
} 