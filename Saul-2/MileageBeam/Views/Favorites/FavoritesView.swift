import SwiftUI

struct FavoritesView: View {
    @State private var favoriteTips: [VortexFuelTipNexusModel] = []
    @State private var selectedCategory: String? = nil
    @State private var searchText: String = ""
    
    var filteredTips: [VortexFuelTipNexusModel] {
        var tips = favoriteTips
        
        if let category = selectedCategory {
            tips = tips.filter { $0.transportCategory == category }
        }
        
        if !searchText.isEmpty {
            tips = tips.filter {
                $0.headerTitle.localizedCaseInsensitiveContains(searchText) ||
                $0.contentDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return tips
    }
    
    var groupedTips: [String: [VortexFuelTipNexusModel]] {
        Dictionary(grouping: filteredTips) { $0.contextScenario }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if favoriteTips.isEmpty {
                        emptyStateView
                    } else {
                        searchAndFilterSection
                        favoritesList
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                
                TextField("Search favorites...", text: $searchText)
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                    }
                }
            }
            .padding()
            .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterButton(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    
                    FilterButton(title: "Car", isSelected: selectedCategory == "Car") {
                        selectedCategory = "Car"
                    }
                    
                    FilterButton(title: "Motorcycle", isSelected: selectedCategory == "Motorcycle") {
                        selectedCategory = "Motorcycle"
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
    }
    
    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if filteredTips.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
                        Text("No favorites found")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    ForEach(Array(groupedTips.keys.sorted()), id: \.self) { scenario in
                        scenarioSection(scenario: scenario, tips: groupedTips[scenario] ?? [])
                    }
                }
            }
            .padding()
        }
    }
    
    private func scenarioSection(scenario: String, tips: [VortexFuelTipNexusModel]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(scenario)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.titleZephyr)
                .padding(.horizontal, 4)
            
            ForEach(tips) { tip in
                NavigationLink(destination: TipDetailZephyrView(tipId: tip.id)) {
                    FavoriteTipCard(tip: tip)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 80))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Favorites Yet")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                
                Text("Start favoriting tips to save them for quick access")
                    .font(.system(size: 16))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: MainZephyrView()) {
                Text("Browse Tips")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(ZephyrColorScheme.buttonZephyr)
                    .cornerRadius(16)
            }
        }
        .padding()
    }
    
    private func loadFavorites() {
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(20)
        }
    }
}

struct FavoriteTipCard: View {
    let tip: VortexFuelTipNexusModel
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(tip.headerTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.titleZephyr)
                    .lineLimit(2)
                
                Text(tip.contentDescription)
                    .font(.system(size: 14))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.8))
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Label(tip.transportCategory, systemImage: tip.transportCategory == "Car" ? "car.fill" : "bicycle")
                        .font(.system(size: 12))
                        .foregroundColor(ZephyrColorScheme.categoryZephyr)
                }
            }
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundColor(ZephyrColorScheme.selectedFilterZephyr)
                .font(.system(size: 24))
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: ZephyrColorScheme.shadowZephyr, radius: 4, x: 0, y: 2)
    }
}

