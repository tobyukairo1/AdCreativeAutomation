import SwiftUI

struct CampaignListView: View {
    @StateObject private var viewModel = CampaignsViewModel()
    @State private var showingNewCampaign = false
    @State private var selectedCampaign: Campaign?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading campaigns...")
                } else if viewModel.campaigns.isEmpty {
                    EmptyStateView()
                } else {
                    campaignList
                }
            }
            .navigationTitle("Campaigns")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewCampaign = true }) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingNewCampaign) {
                NewCampaignView(viewModel: viewModel)
            }
            .sheet(item: $selectedCampaign) { campaign in
                CampaignDetailView(campaign: campaign, viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadCampaigns()
        }
    }
    
    private var campaignList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.campaigns) { campaign in
                    CampaignCardView(campaign: campaign)
                        .onTapGesture {
                            selectedCampaign = campaign
                        }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadCampaigns()
        }
    }
}

struct CampaignCardView: View {
    let campaign: Campaign
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(campaign.name)
                    .font(.headline)
                Spacer()
                StatusBadgeView(status: campaign.status)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(campaign.platform.rawValue, systemImage: platformIcon)
                        .foregroundColor(.secondary)
                    Label(campaign.objective.rawValue, systemImage: "target")
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Budget: $\(String(format: "%.2f", campaign.budget))")
                        .foregroundColor(.secondary)
                    if let performance = campaign.performance {
                        Text("ROAS: \(String(format: "%.1fx", performance.roas))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .font(.subheadline)
            
            if let performance = campaign.performance {
                PerformanceBarView(performance: performance)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var platformIcon: String {
        switch campaign.platform {
        case .facebook:
            return "f.circle.fill"
        case .tiktok:
            return "music.note.tv"
        }
    }
}

struct StatusBadgeView: View {
    let status: CampaignStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .draft:
            return .gray
        case .active:
            return .green
        case .paused:
            return .orange
        case .completed:
            return .blue
        }
    }
}

struct PerformanceBarView: View {
    let performance: CampaignPerformance
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(min(performance.ctr / 100, 1)))
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
        }
        .frame(height: 4)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No Campaigns Yet")
                .font(.headline)
            Text("Tap + to create your first campaign")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CampaignListView()
} 