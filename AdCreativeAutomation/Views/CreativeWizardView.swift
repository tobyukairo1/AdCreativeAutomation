import SwiftUI

struct CreativeWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreativeWizardViewModel()
    @State private var currentStep = 0
    @State private var showError = false
    @State private var errorMessage = ""
    
    let campaign: Campaign
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                TabView(selection: $currentStep) {
                    ProductSelectionView(viewModel: viewModel)
                        .tag(0)
                    
                    StyleSelectionView(viewModel: viewModel)
                        .tag(1)
                    
                    ConceptGenerationView(viewModel: viewModel)
                        .tag(2)
                    
                    MediaGenerationView(viewModel: viewModel)
                        .tag(3)
                    
                    AdCopyView(viewModel: viewModel, campaign: campaign)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                navigationButtons
            }
            .navigationTitle("Create Creative")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * CGFloat(currentStep + 1) / 5)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .frame(height: 4)
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    currentStep -= 1
                }
            }
            
            Spacer()
            
            if currentStep < 4 {
                Button("Next") {
                    moveToNextStep()
                }
                .disabled(!canMoveToNextStep)
            } else {
                Button("Create") {
                    createCreative()
                }
                .disabled(viewModel.generatedAdCopy == nil)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2)),
            alignment: .top
        )
    }
    
    private var canMoveToNextStep: Bool {
        switch currentStep {
        case 0:
            return viewModel.product != nil
        case 1:
            return viewModel.selectedStyle != nil
        case 2:
            return viewModel.selectedConcept != nil
        case 3:
            return viewModel.generatedMedia != nil
        default:
            return false
        }
    }
    
    private func moveToNextStep() {
        if canMoveToNextStep && currentStep < 4 {
            currentStep += 1
        }
    }
    
    private func createCreative() {
        Task {
            do {
                let creative = try await viewModel.createCreative()
                // Here we would update the campaign with the new creative
                dismiss()
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
}

struct ProductSelectionView: View {
    @ObservedObject var viewModel: CreativeWizardViewModel
    @State private var searchText = ""
    
    var body: some View {
        List {
            Section {
                TextField("Search Products", text: $searchText)
            }
            
            Section {
                // Mock products for now
                ForEach(mockProducts) { product in
                    ProductRowView(
                        product: product,
                        isSelected: viewModel.product?.id == product.id
                    )
                    .onTapGesture {
                        viewModel.setProduct(product)
                    }
                }
            }
        }
    }
    
    private var mockProducts: [Product] {
        [
            Product(
                id: UUID(),
                title: "Premium Wireless Headphones",
                description: "High-quality wireless headphones with noise cancellation",
                price: 199.99,
                type: "Electronics",
                features: ["Noise cancellation", "40h battery life", "Premium sound"]
            ),
            Product(
                id: UUID(),
                title: "Smart Fitness Watch",
                description: "Track your fitness goals with this advanced smartwatch",
                price: 299.99,
                type: "Wearables",
                features: ["Heart rate monitor", "GPS tracking", "Water resistant"]
            )
        ]
    }
}

struct StyleSelectionView: View {
    @ObservedObject var viewModel: CreativeWizardViewModel
    
    var body: some View {
        List {
            Section(header: Text("Visual Style")) {
                ForEach(CreativeStyle.VisualStyle.allCases, id: \.self) { style in
                    StyleOptionRow(
                        title: style.rawValue,
                        isSelected: viewModel.selectedStyle?.visualStyle == style
                    ) {
                        viewModel.setStyle(CreativeStyle(visualStyle: style))
                    }
                }
            }
            
            Section(header: Text("Platforms")) {
                ForEach(AdPlatform.allCases, id: \.self) { platform in
                    StyleOptionRow(
                        title: platform.rawValue,
                        isSelected: viewModel.selectedPlatforms.contains(platform)
                    ) {
                        viewModel.togglePlatform(platform)
                    }
                }
            }
        }
    }
}

struct ConceptGenerationView: View {
    @ObservedObject var viewModel: CreativeWizardViewModel
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Generating concepts...")
            } else if viewModel.generatedConcepts.isEmpty {
                Button(action: generateConcepts) {
                    Label("Generate Concepts", systemImage: "wand.and.stars")
                }
            } else {
                ForEach(viewModel.generatedConcepts, id: \.self) { concept in
                    ConceptRowView(
                        concept: concept,
                        isSelected: viewModel.selectedConcept == concept
                    )
                    .onTapGesture {
                        viewModel.selectConcept(concept)
                    }
                }
                
                Button("Generate More", action: generateConcepts)
            }
        }
    }
    
    private func generateConcepts() {
        Task {
            try? await viewModel.generateConcepts()
        }
    }
}

struct MediaGenerationView: View {
    @ObservedObject var viewModel: CreativeWizardViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Generating media...")
            } else if let media = viewModel.generatedMedia {
                // Display generated media
                Text("Media generated successfully!")
            } else {
                Button(action: generateMedia) {
                    Label("Generate Media", systemImage: "photo.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    private func generateMedia() {
        Task {
            try? await viewModel.generateMedia()
        }
    }
}

struct AdCopyView: View {
    @ObservedObject var viewModel: CreativeWizardViewModel
    let campaign: Campaign
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Generating ad copy...")
            } else if let adCopy = viewModel.generatedAdCopy {
                Section("Headline") {
                    Text(adCopy.headline)
                        .font(.headline)
                }
                
                Section("Description") {
                    Text(adCopy.description)
                }
                
                Section("Call to Action") {
                    Text(adCopy.callToAction)
                        .fontWeight(.medium)
                }
                
                Section("Keywords") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(adCopy.keywords, id: \.self) { keyword in
                                Text(keyword)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
            } else {
                Button(action: { generateAdCopy() }) {
                    Label("Generate Ad Copy", systemImage: "text.quote")
                }
            }
        }
    }
    
    private func generateAdCopy() {
        Task {
            try? await viewModel.generateAdCopy(for: campaign.platform)
        }
    }
}

struct ProductRowView: View {
    let product: Product
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StyleOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ConceptRowView: View {
    let concept: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(concept)
                .padding(.vertical, 8)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    CreativeWizardView(
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