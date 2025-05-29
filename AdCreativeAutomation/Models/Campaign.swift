import Foundation

enum CampaignStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case active = "Active"
    case paused = "Paused"
    case completed = "Completed"
}

enum AdPlatform: String, Codable, CaseIterable {
    case facebook = "Facebook"
    case tiktok = "TikTok"
}

enum CampaignObjective: String, Codable, CaseIterable {
    case awareness = "Brand Awareness"
    case traffic = "Website Traffic"
    case engagement = "Social Engagement"
    case sales = "Sales & Conversions"
    case leads = "Lead Generation"
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case all
    
    var id: String { rawValue }
}

struct TargetAudience: Codable {
    let ageRange: ClosedRange<Int>
    let locations: [String]
    let interests: [String]
    let gender: Gender?
    let languages: [String]
}

struct Campaign: Identifiable, Codable {
    let id: UUID
    let name: String
    let objective: CampaignObjective
    let platform: AdPlatform
    let budget: Double
    let startDate: Date
    let endDate: Date
    var status: CampaignStatus
    var creatives: [Creative]
    var performance: CampaignPerformance?
    let targetAudience: TargetAudience
    let roas: Double
    let impressions: Int
    let ctr: Double
    let spend: Double
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        objective: CampaignObjective,
        platform: AdPlatform,
        budget: Double,
        startDate: Date,
        endDate: Date,
        status: CampaignStatus,
        creatives: [Creative],
        performance: CampaignPerformance?,
        targetAudience: TargetAudience,
        roas: Double,
        impressions: Int,
        ctr: Double,
        spend: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.objective = objective
        self.platform = platform
        self.budget = budget
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.creatives = creatives
        self.performance = performance
        self.targetAudience = targetAudience
        self.roas = roas
        self.impressions = impressions
        self.ctr = ctr
        self.spend = spend
        self.createdAt = createdAt
    }
}

struct CampaignPerformance: Codable {
    let impressions: Int
    let clicks: Int
    let ctr: Double
    let spend: Double
    let conversions: Int
    let revenue: Double
    let costPerClick: Double
    let costPerConversion: Double
    let roas: Double
}

enum CampaignFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case paused = "Paused"
    case completed = "Completed"
    case draft = "Draft"
    
    var id: String { rawValue }
} 