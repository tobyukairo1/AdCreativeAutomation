import Foundation
import UIKit

struct Creative: Identifiable, Codable {
    let id: UUID
    let productId: UUID
    let type: CreativeType
    let format: CreativeFormat
    let mediaUrl: String
    let headline: String
    let description: String
    let callToAction: String
    var performance: CreativePerformance?
    
    var ctr: Double {
        guard performance?.impressions > 0 else { return 0 }
        return Double(performance?.clicks ?? 0) / Double(performance?.impressions ?? 0) * 100
    }
    
    var engagementRate: Double {
        guard performance?.impressions > 0 else { return 0 }
        return Double(performance?.engagements ?? 0) / Double(performance?.impressions ?? 0) * 100
    }
    
    var conversionRate: Double {
        guard performance?.clicks > 0 else { return 0 }
        return Double(performance?.conversions ?? 0) / Double(performance?.clicks ?? 0) * 100
    }
}

enum CreativeType: String, Codable {
    case image = "Image"
    case video = "Video"
    case carousel = "Carousel"
    case collection = "Collection"
}

enum CreativeFormat: String, Codable {
    case square = "Square"
    case portrait = "Portrait"
    case landscape = "Landscape"
    case story = "Story"
}

enum VisualStyle: String, Codable, CaseIterable, Identifiable {
    case minimal = "Minimal & Clean"
    case bold = "Bold & Dynamic"
    case lifestyle = "Lifestyle & Natural"
    case luxury = "Luxury & Premium"
    case playful = "Playful & Fun"
    case corporate = "Corporate & Professional"
    
    var id: String { rawValue }
}

enum ToneStyle: String, Codable, CaseIterable, Identifiable {
    case professional = "Professional"
    case casual = "Casual"
    case humorous = "Humorous"
    case serious = "Serious"
    case inspirational = "Inspirational"
    case dramatic = "Dramatic"
    
    var id: String { rawValue }
}

enum HookStyle: String, Codable, CaseIterable, Identifiable {
    case problem = "Problem-Solution"
    case benefit = "Direct Benefit"
    case curiosity = "Curiosity"
    case urgency = "Urgency"
    case social = "Social Proof"
    
    var id: String { rawValue }
}

struct CreativeStyle: Codable {
    let visualStyle: VisualStyle
    let tone: ToneStyle
    let hookStyle: HookStyle
    let customStyle: String
    
    init(
        visualStyle: VisualStyle = .modern,
        tone: ToneStyle = .professional,
        hookStyle: HookStyle = .benefit,
        customStyle: String = ""
    ) {
        self.visualStyle = visualStyle
        self.tone = tone
        self.hookStyle = hookStyle
        self.customStyle = customStyle
    }
}

struct CreativePerformance: Codable {
    let impressions: Int
    let clicks: Int
    let ctr: Double
    let conversions: Int
    let spend: Double
    let revenue: Double
    
    var engagementRate: Double {
        guard impressions > 0 else { return 0 }
        return Double(clicks) / Double(impressions) * 100
    }
}

struct CreativeTemplate: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var type: CreativeType
    var format: CreativeFormat
    var previewImage: UIImage?
    var tags: [String]
}

enum AspectRatio: String, Codable {
    case square = "1:1"
    case portrait = "4:5"
    case landscape = "16:9"
    case story = "9:16"
    
    var dimensions: (width: CGFloat, height: CGFloat) {
        switch self {
        case .square:
            return (1, 1)
        case .portrait:
            return (4, 5)
        case .landscape:
            return (16, 9)
        case .story:
            return (9, 16)
        }
    }
} 