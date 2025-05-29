import Foundation
import Combine

@MainActor
class CampaignsViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let aiService: AIServiceProtocol
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        aiService: AIServiceProtocol = AIService(),
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.aiService = aiService
        self.networkService = networkService
    }
    
    func loadCampaigns() async {
        isLoading = true
        error = nil
        
        do {
            // In a real app, this would fetch from an API
            // For now, load mock data
            campaigns = try await fetchMockCampaigns()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func createCampaign(
        name: String,
        objective: CampaignObjective,
        platform: AdPlatform,
        budget: Double,
        startDate: Date,
        endDate: Date
    ) async throws -> Campaign {
        let campaign = Campaign(
            id: UUID(),
            name: name,
            objective: objective,
            platform: platform,
            budget: budget,
            startDate: startDate,
            endDate: endDate,
            status: .draft,
            creatives: [],
            performance: nil
        )
        
        campaigns.append(campaign)
        return campaign
    }
    
    func updateCampaign(_ campaign: Campaign) async throws {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else {
            throw CampaignError.notFound
        }
        
        campaigns[index] = campaign
    }
    
    func deleteCampaign(_ campaign: Campaign) async throws {
        campaigns.removeAll { $0.id == campaign.id }
    }
    
    func updateCampaignStatus(_ campaign: Campaign, status: CampaignStatus) async throws {
        var updatedCampaign = campaign
        updatedCampaign.status = status
        try await updateCampaign(updatedCampaign)
    }
    
    func fetchCampaignPerformance(for campaign: Campaign) async throws {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else {
            throw CampaignError.notFound
        }
        
        let performance = try await aiService.fetchCampaignPerformance(campaign.id)
        campaigns[index].performance = performance
    }
    
    private func fetchMockCampaigns() async throws -> [Campaign] {
        // Mock data for testing
        return [
            Campaign(
                id: UUID(),
                name: "Summer Sale 2024",
                objective: .sales,
                platform: .facebook,
                budget: 1000.0,
                startDate: Date(),
                endDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
                status: .active,
                creatives: [],
                performance: nil
            ),
            Campaign(
                id: UUID(),
                name: "Brand Awareness Q2",
                objective: .awareness,
                platform: .tiktok,
                budget: 2000.0,
                startDate: Date(),
                endDate: Date().addingTimeInterval(60 * 24 * 60 * 60),
                status: .draft,
                creatives: [],
                performance: nil
            )
        ]
    }
}

enum CampaignError: LocalizedError {
    case notFound
    case invalidData
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Campaign not found"
        case .invalidData:
            return "Invalid campaign data"
        case .updateFailed:
            return "Failed to update campaign"
        }
    }
} 