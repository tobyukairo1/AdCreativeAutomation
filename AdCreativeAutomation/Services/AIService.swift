import Foundation

protocol AIServiceProtocol {
    func generateConcepts(
        product: Product,
        style: CreativeStyle,
        platforms: [AdPlatform],
        variations: Int
    ) async throws -> [String]
    
    func generateMedia(
        concept: String,
        product: Product,
        style: CreativeStyle
    ) async throws -> MediaGeneration
    
    func fetchCampaignPerformance(_ campaignId: UUID) async throws -> CampaignPerformance
    
    func generateAdCopy(
        product: Product,
        style: CreativeStyle,
        platform: AdPlatform
    ) async throws -> AdCopy
}

struct MediaGeneration {
    let data: Data
    let type: CreativeType
    let format: CreativeFormat
}

struct AdCopy {
    let headline: String
    let description: String
    let callToAction: String
    let keywords: [String]
}

class AIService: AIServiceProtocol {
    private let openAIService: OpenAIServiceProtocol
    private let configService: ConfigServiceProtocol
    
    init(
        openAIService: OpenAIServiceProtocol = OpenAIService(),
        configService: ConfigServiceProtocol = ConfigService()
    ) {
        self.openAIService = openAIService
        self.configService = configService
    }
    
    func generateConcepts(
        product: Product,
        style: CreativeStyle,
        platforms: [AdPlatform],
        variations: Int
    ) async throws -> [String] {
        let prompt = createConceptPrompt(
            product: product,
            style: style,
            platforms: platforms
        )
        
        return try await openAIService.generateText(
            prompt: prompt,
            variations: variations
        )
    }
    
    func generateMedia(
        concept: String,
        product: Product,
        style: CreativeStyle
    ) async throws -> MediaGeneration {
        let prompt = createMediaPrompt(
            concept: concept,
            product: product,
            style: style
        )
        
        let imageData = try await openAIService.generateImage(prompt: prompt)
        
        return MediaGeneration(
            data: imageData,
            type: .image,
            format: .square
        )
    }
    
    func fetchCampaignPerformance(_ campaignId: UUID) async throws -> CampaignPerformance {
        // In a real app, this would fetch from an analytics service
        // For now, return mock data
        return CampaignPerformance(
            impressions: Int.random(in: 1000...10000),
            clicks: Int.random(in: 50...500),
            ctr: Double.random(in: 1...5),
            spend: Double.random(in: 100...1000),
            conversions: Int.random(in: 10...100),
            revenue: Double.random(in: 200...2000),
            costPerClick: Double.random(in: 0.5...2.0),
            costPerConversion: Double.random(in: 5...20),
            roas: Double.random(in: 1...5)
        )
    }
    
    func generateAdCopy(
        product: Product,
        style: CreativeStyle,
        platform: AdPlatform
    ) async throws -> AdCopy {
        let prompt = createAdCopyPrompt(
            product: product,
            style: style,
            platform: platform
        )
        
        let response = try await openAIService.generateText(
            prompt: prompt,
            variations: 1
        )
        
        guard let copyText = response.first else {
            throw AIError.noGeneratedContent
        }
        
        // Parse the response into structured ad copy
        // In a real app, we'd use more sophisticated parsing
        let components = copyText.components(separatedBy: "\n\n")
        
        return AdCopy(
            headline: components.first ?? "",
            description: components.dropFirst().first ?? "",
            callToAction: components.last ?? "",
            keywords: extractKeywords(from: copyText)
        )
    }
    
    private func createConceptPrompt(
        product: Product,
        style: CreativeStyle,
        platforms: [AdPlatform]
    ) -> String {
        // Build a detailed prompt for the AI
        return """
        Create advertising concepts for the following product:
        
        Product: \(product.title)
        Description: \(product.description)
        Price: $\(product.price)
        Target Platforms: \(platforms.map { $0.rawValue }.joined(separator: ", "))
        
        Style Guidelines:
        - Visual Style: \(style.visualStyle.rawValue)
        - Tone: \(style.tone.rawValue)
        - Hook Style: \(style.hookStyle.rawValue)
        \(style.customStyle.isEmpty ? "" : "- Custom Style: \(style.customStyle)")
        
        Generate creative concepts that:
        1. Highlight key product benefits
        2. Appeal to the target audience
        3. Follow platform-specific best practices
        4. Incorporate the specified style guidelines
        """
    }
    
    private func createMediaPrompt(
        concept: String,
        product: Product,
        style: CreativeStyle
    ) -> String {
        return """
        Create an advertisement image based on this concept:
        \(concept)
        
        Product Details:
        - Name: \(product.title)
        - Type: \(product.type)
        
        Style:
        - Visual Style: \(style.visualStyle.rawValue)
        - Tone: \(style.tone.rawValue)
        
        Requirements:
        - Professional quality
        - Clear product focus
        - Engaging visual composition
        - Brand appropriate
        """
    }
    
    private func createAdCopyPrompt(
        product: Product,
        style: CreativeStyle,
        platform: AdPlatform
    ) -> String {
        return """
        Write advertising copy for:
        
        Product: \(product.title)
        Platform: \(platform.rawValue)
        Price: $\(product.price)
        
        Style:
        - Tone: \(style.tone.rawValue)
        - Hook: \(style.hookStyle.rawValue)
        
        Include:
        1. Attention-grabbing headline
        2. Compelling description
        3. Clear call-to-action
        
        Key Features:
        \(product.features?.joined(separator: "\n") ?? "")
        """
    }
    
    private func extractKeywords(from text: String) -> [String] {
        // In a real app, we'd use NLP to extract keywords
        // For now, return some basic words
        return text.components(separatedBy: " ")
            .filter { $0.count > 5 }
            .prefix(5)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
    }
}

enum AIError: LocalizedError {
    case noGeneratedContent
    case invalidResponse
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .noGeneratedContent:
            return "No content was generated"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .processingFailed:
            return "Failed to process AI response"
        }
    }
} 