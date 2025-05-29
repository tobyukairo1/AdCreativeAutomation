import Foundation
import Combine

@MainActor
class CreativeWizardViewModel: ObservableObject {
    @Published var product: Product?
    @Published var selectedStyle: CreativeStyle?
    @Published var selectedPlatforms: Set<AdPlatform> = []
    @Published var generatedConcepts: [String] = []
    @Published var selectedConcept: String?
    @Published var generatedMedia: MediaGeneration?
    @Published var generatedAdCopy: AdCopy?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let aiService: AIServiceProtocol
    private let mediaService: MediaServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        aiService: AIServiceProtocol = AIService(),
        mediaService: MediaServiceProtocol = MediaService()
    ) {
        self.aiService = aiService
        self.mediaService = mediaService
    }
    
    func setProduct(_ product: Product) {
        self.product = product
    }
    
    func setStyle(_ style: CreativeStyle) {
        self.selectedStyle = style
    }
    
    func togglePlatform(_ platform: AdPlatform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
    }
    
    func generateConcepts() async throws {
        guard let product = product,
              let style = selectedStyle,
              !selectedPlatforms.isEmpty else {
            throw CreativeError.missingRequiredData
        }
        
        isLoading = true
        error = nil
        
        do {
            generatedConcepts = try await aiService.generateConcepts(
                product: product,
                style: style,
                platforms: Array(selectedPlatforms),
                variations: 3
            )
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    func selectConcept(_ concept: String) {
        selectedConcept = concept
    }
    
    func generateMedia() async throws {
        guard let product = product,
              let style = selectedStyle,
              let concept = selectedConcept else {
            throw CreativeError.missingRequiredData
        }
        
        isLoading = true
        error = nil
        
        do {
            let mediaGeneration = try await aiService.generateMedia(
                concept: concept,
                product: product,
                style: style
            )
            
            // Process and optimize the media
            let processedData = try await mediaService.processMedia(
                mediaGeneration.data,
                type: mediaGeneration.type
            )
            
            self.generatedMedia = MediaGeneration(
                data: processedData,
                type: mediaGeneration.type,
                format: mediaGeneration.format
            )
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    func generateAdCopy(for platform: AdPlatform) async throws {
        guard let product = product,
              let style = selectedStyle else {
            throw CreativeError.missingRequiredData
        }
        
        isLoading = true
        error = nil
        
        do {
            generatedAdCopy = try await aiService.generateAdCopy(
                product: product,
                style: style,
                platform: platform
            )
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    func createCreative() async throws -> Creative {
        guard let product = product,
              let media = generatedMedia,
              let adCopy = generatedAdCopy else {
            throw CreativeError.missingRequiredData
        }
        
        return Creative(
            id: UUID(),
            productId: product.id,
            type: media.type,
            format: media.format,
            mediaUrl: "", // This would be set after uploading to storage
            headline: adCopy.headline,
            description: adCopy.description,
            callToAction: adCopy.callToAction,
            performance: nil
        )
    }
}

enum CreativeError: LocalizedError {
    case missingRequiredData
    case generationFailed
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .missingRequiredData:
            return "Missing required data for creative generation"
        case .generationFailed:
            return "Failed to generate creative"
        case .processingFailed:
            return "Failed to process creative"
        }
    }
} 