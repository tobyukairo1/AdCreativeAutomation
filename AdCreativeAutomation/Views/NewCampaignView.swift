import SwiftUI

struct NewCampaignView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CampaignsViewModel
    
    @State private var name = ""
    @State private var objective = CampaignObjective.awareness
    @State private var platform = AdPlatform.facebook
    @State private var budget = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Campaign Details")) {
                    TextField("Campaign Name", text: $name)
                    
                    Picker("Objective", selection: $objective) {
                        ForEach(CampaignObjective.allCases, id: \.self) { objective in
                            Text(objective.rawValue)
                                .tag(objective)
                        }
                    }
                    
                    Picker("Platform", selection: $platform) {
                        ForEach(AdPlatform.allCases, id: \.self) { platform in
                            Text(platform.rawValue)
                                .tag(platform)
                        }
                    }
                }
                
                Section(header: Text("Budget & Schedule")) {
                    TextField("Budget ($)", text: $budget)
                        .keyboardType(.decimalPad)
                    
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        displayedComponents: [.date]
                    )
                    
                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: [.date]
                    )
                }
            }
            .navigationTitle("New Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createCampaign()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        !budget.isEmpty &&
        Double(budget) != nil &&
        startDate < endDate
    }
    
    private func createCampaign() {
        guard let budgetValue = Double(budget) else {
            showError(message: "Invalid budget value")
            return
        }
        
        Task {
            do {
                _ = try await viewModel.createCampaign(
                    name: name,
                    objective: objective,
                    platform: platform,
                    budget: budgetValue,
                    startDate: startDate,
                    endDate: endDate
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    NewCampaignView(viewModel: CampaignsViewModel())
} 