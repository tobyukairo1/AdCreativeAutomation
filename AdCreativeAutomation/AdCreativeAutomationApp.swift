import SwiftUI

@main
struct AdCreativeAutomationApp: App {
    init() {
        // Configure appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure list appearance
        UITableView.appearance().backgroundColor = .systemGroupedBackground
        UITableViewCell.appearance().backgroundColor = .systemBackground
    }
    
    var body: some Scene {
        WindowGroup {
            CampaignListView()
        }
    }
} 