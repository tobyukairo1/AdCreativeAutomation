import Foundation

struct PerformanceDataPoint: Identifiable, Codable {
    let id: UUID
    let date: Date
    let spend: Double
    let revenue: Double
    let impressions: Int
    let clicks: Int
    let engagements: Int
    let conversions: Int
    
    var roas: Double {
        guard spend > 0 else { return 0 }
        return revenue / spend
    }
    
    var ctr: Double {
        guard impressions > 0 else { return 0 }
        return Double(clicks) / Double(impressions) * 100
    }
    
    var engagementRate: Double {
        guard impressions > 0 else { return 0 }
        return Double(engagements) / Double(impressions) * 100
    }
    
    var conversionRate: Double {
        guard clicks > 0 else { return 0 }
        return Double(conversions) / Double(clicks) * 100
    }
    
    init(
        id: UUID = UUID(),
        date: Date,
        spend: Double,
        revenue: Double,
        impressions: Int,
        clicks: Int,
        engagements: Int = 0,
        conversions: Int = 0
    ) {
        self.id = id
        self.date = date
        self.spend = spend
        self.revenue = revenue
        self.impressions = impressions
        self.clicks = clicks
        self.engagements = engagements
        self.conversions = conversions
    }
} 