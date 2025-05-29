import SwiftUI

struct CampaignDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CampaignsViewModel
    @State private var showingCreativeWizard = false
    @State private var showingStatusPicker = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let campaign: Campaign
    
    var body: some View {
        NavigationView {
            List {
                campaignInfoSection
                performanceSection
                creativesSection
            }
            .navigationTitle(campaign.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    statusButton
                }
            }
            .refreshable {
                await refreshCampaign()
            }
            .sheet(isPresented: $showingCreativeWizard) {
                CreativeWizardView(campaign: campaign)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .task {
            await refreshCampaign()
        }
    }
    
    private var campaignInfoSection: some View {
        Section("Campaign Info") {
            LabeledContent("Platform", value: campaign.platform.rawValue)
            LabeledContent("Objective", value: campaign.objective.rawValue)
            LabeledContent("Budget", value: "$\(String(format: "%.2f", campaign.budget))")
            LabeledContent("Start Date", value: campaign.startDate.formatted(date: .abbreviated, time: .omitted))
            LabeledContent("End Date", value: campaign.endDate.formatted(date: .abbreviated, time: .omitted))
        }
    }
    
    private var performanceSection: some View {
        Section("Performance") {
            if let performance = campaign.performance {
                PerformanceMetricView(
                    title: "Impressions",
                    value: "\(performance.impressions)",
                    icon: "eye.fill"
                )
                PerformanceMetricView(
                    title: "Clicks",
                    value: "\(performance.clicks)",
                    icon: "hand.tap.fill"
                )
                PerformanceMetricView(
                    title: "CTR",
                    value: String(format: "%.2f%%", performance.ctr),
                    icon: "percent"
                )
                PerformanceMetricView(
                    title: "ROAS",
                    value: String(format: "%.1fx", performance.roas),
                    icon: "chart.line.uptrend.xyaxis"
                )
            } else {
                Text("No performance data available")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var creativesSection: some View {
        Section("Creatives") {
            if campaign.creatives.isEmpty {
                Button(action: { showingCreativeWizard = true }) {
                    Label("Add Creative", systemImage: "plus.circle.fill")
                }
            } else {
                ForEach(campaign.creatives) { creative in
                    CreativeRowView(creative: creative)
                }
                Button(action: { showingCreativeWizard = true }) {
                    Label("Add Another Creative", systemImage: "plus.circle")
                }
            }
        }
    }
    
    private var statusButton: some View {
        Menu {
            ForEach(CampaignStatus.allCases, id: \.self) { status in
                Button(action: { updateStatus(to: status) }) {
                    HStack {
                        Text(status.rawValue)
                        if status == campaign.status {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            StatusBadgeView(status: campaign.status)
        }
    }
    
    private func updateStatus(to newStatus: CampaignStatus) {
        Task {
            do {
                try await viewModel.updateCampaignStatus(campaign, status: newStatus)
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func refreshCampaign() async {
        isLoading = true
        do {
            try await viewModel.fetchCampaignPerformance(for: campaign)
            isLoading = false
        } catch {
            showError(message: error.localizedDescription)
            isLoading = false
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct PerformanceMetricView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct CreativeRowView: View {
    let creative: Creative
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(creative.headline)
                .font(.headline)
            Text(creative.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let performance = creative.performance {
                HStack {
                    Label("\(performance.impressions)", systemImage: "eye.fill")
                    Spacer()
                    Label("\(performance.clicks)", systemImage: "hand.tap.fill")
                    Spacer()
                    Label(String(format: "%.2f%%", performance.ctr), systemImage: "percent")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CampaignDetailView(
        viewModel: CampaignsViewModel(),
        campaign: Campaign(
            id: UUID(),
            name: "Test Campaign",
            objective: .sales,
            platform: .facebook,
            budget: 1000,
            startDate: Date(),
            endDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
            status: .active,
            creatives: [],
            performance: nil
        )
    )
} 