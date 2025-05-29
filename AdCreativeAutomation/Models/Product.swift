import Foundation
import UIKit

struct Product: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let price: Double
    let type: String
    let features: [String]?
    var images: [String]?
    var variants: [ProductVariant]?
    var metadata: [String: String]?
}

struct ProductImage: Codable {
    let id: UUID
    var url: URL
    var position: Int
    var alt: String?
    var width: Int
    var height: Int
    var localImage: UIImage?
}

struct ProductVariant: Identifiable, Codable {
    let id: UUID
    let name: String
    let sku: String
    let price: Double
    let attributes: [String: String]
    var stockLevel: Int
}

struct ProductMetadata: Codable {
    var seoTitle: String?
    var seoDescription: String?
    var keywords: [String]
    var targetAudience: TargetAudience?
    var performanceMetrics: ProductPerformanceMetrics?
    var adHistory: [AdHistoryEntry]
}

struct ProductPerformanceMetrics: Codable {
    var totalSales: Int
    var revenue: Decimal
    var averageOrderValue: Decimal
    var conversionRate: Double
    var viewCount: Int
    var bestPerformingAd: AdHistoryEntry?
}

struct AdHistoryEntry: Identifiable, Codable {
    let id: UUID
    var campaignId: UUID
    var platform: AdPlatform
    var startDate: Date
    var endDate: Date?
    var spend: Decimal
    var impressions: Int
    var clicks: Int
    var conversions: Int
    var revenue: Decimal
    
    var roas: Double {
        guard spend > 0 else { return 0 }
        return (revenue as NSDecimalNumber).doubleValue / (spend as NSDecimalNumber).doubleValue
    }
    
    var ctr: Double {
        guard impressions > 0 else { return 0 }
        return Double(clicks) / Double(impressions) * 100
    }
}

enum ProductStatus: String, Codable {
    case active = "Active"
    case draft = "Draft"
    case archived = "Archived"
} 