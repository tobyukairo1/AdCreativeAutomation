import Foundation

protocol OpenAIServiceProtocol {
    func generateText(prompt: String, variations: Int) async throws -> [String]
    func generateImage(prompt: String) async throws -> Data
}

class OpenAIService: OpenAIServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let configService: ConfigServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        configService: ConfigServiceProtocol = ConfigService()
    ) {
        self.networkService = networkService
        self.configService = configService
    }
    
    func generateText(prompt: String, variations: Int) async throws -> [String] {
        let endpoint = APIEndpoint(path: "/v1/completions")
        
        struct CompletionRequest: Codable {
            let model = "gpt-4"
            let prompt: String
            let n: Int
            let maxTokens = 1000
            let temperature = 0.7
        }
        
        struct CompletionResponse: Codable {
            struct Choice: Codable {
                let text: String
            }
            let choices: [Choice]
        }
        
        let request = CompletionRequest(
            prompt: prompt,
            n: variations
        )
        
        let response: CompletionResponse = try await networkService.request(
            endpoint,
            method: .post,
            body: request
        )
        
        return response.choices.map { $0.text }
    }
    
    func generateImage(prompt: String) async throws -> Data {
        let endpoint = APIEndpoint(path: "/v1/images/generations")
        
        struct ImageRequest: Codable {
            let prompt: String
            let n = 1
            let size = "1024x1024"
            let responseFormat = "b64_json"
        }
        
        struct ImageResponse: Codable {
            struct ImageData: Codable {
                let b64Json: String
            }
            let data: [ImageData]
        }
        
        let request = ImageRequest(prompt: prompt)
        
        let response: ImageResponse = try await networkService.request(
            endpoint,
            method: .post,
            body: request
        )
        
        guard let imageData = response.data.first?.b64Json.data(using: .utf8),
              let decodedData = Data(base64Encoded: imageData) else {
            throw OpenAIError.invalidImageData
        }
        
        return decodedData
    }
}

enum OpenAIError: LocalizedError {
    case invalidImageData
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Invalid image data received"
        case .apiError(let message):
            return "OpenAI API error: \(message)"
        }
    }
} 