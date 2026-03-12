import SwiftUI

struct MainZephyrView: View {
    @StateObject private var viewModel = ZenithTipListCipherViewModel(dataRepository: BoltFuelTipRepository())
    @State private var showStatisticsZephyr = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    vehicleSelectorZephyr
                    scenarioFiltersZephyr
                    searchBarZephyr
                    
                    ScrollView {
                        tipsListZephyr
                    }
                }
            }
            .navigationTitle("MileageBeam")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showStatisticsZephyr = true
                    }) {
                        Image(systemName: "chart.pie.fill")
                            .foregroundColor(ZephyrColorScheme.titleZephyr)
                    }
                }
            }
            .sheet(isPresented: $showStatisticsZephyr) {
                StatisticsZephyrView()
            }
        }
    }
    
    private var vehicleSelectorZephyr: some View {
        HStack(spacing: 12) {
            VehicleButtonZephyr(
                title: "Car",
                isSelected: viewModel.currentVehicleSelection == "Car",
                action: {
                    viewModel.currentVehicleSelection = "Car"
                }
            )
            
            VehicleButtonZephyr(
                title: "Motorcycle",
                isSelected: viewModel.currentVehicleSelection == "Motorcycle",
                action: {
                    viewModel.currentVehicleSelection = "Motorcycle"
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var scenarioFiltersZephyr: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ScenarioFilterZephyr(
                    title: "City",
                    isSelected: viewModel.currentScenarioSelection == "City",
                    action: {
                        viewModel.switchScenarioSelection("City")
                    }
                )
                
                ScenarioFilterZephyr(
                    title: "Highway",
                    isSelected: viewModel.currentScenarioSelection == "Highway",
                    action: {
                        viewModel.switchScenarioSelection("Highway")
                    }
                )
                
                ScenarioFilterZephyr(
                    title: "Traffic",
                    isSelected: viewModel.currentScenarioSelection == "Traffic",
                    action: {
                        viewModel.switchScenarioSelection("Traffic")
                    }
                )
                
                ScenarioFilterZephyr(
                    title: "Weather",
                    isSelected: viewModel.currentScenarioSelection == "Weather",
                    action: {
                        viewModel.switchScenarioSelection("Weather")
                    }
                )
                
                ScenarioFilterZephyr(
                    title: "Cold",
                    isSelected: viewModel.currentScenarioSelection == "Cold",
                    action: {
                        viewModel.switchScenarioSelection("Cold")
                    }
                )
                
                ScenarioFilterZephyr(
                    title: "Hot",
                    isSelected: viewModel.currentScenarioSelection == "Hot",
                    action: {
                        viewModel.switchScenarioSelection("Hot")
                    }
                )
                
                ScenarioFilterZephyr(
                    title: "All Scenarios",
                    isSelected: viewModel.currentScenarioSelection == "All Scenarios",
                    action: {
                        viewModel.switchScenarioSelection("All Scenarios")
                    }
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color.clear)
    }
    
    private var searchBarZephyr: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
            
            ZStack(alignment: .leading) {
                if viewModel.searchQueryText.isEmpty {
                    Text("Search fuel saving tips...")
                        .font(.system(size: 18))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
                }
                
                TextField("", text: $viewModel.searchQueryText)
                    .font(.system(size: 18))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            }
            
            if !viewModel.searchQueryText.isEmpty {
                Button(action: {
                    viewModel.searchQueryText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var tipsListZephyr: some View {
        LazyVStack(spacing: 16) {
            Toggle("Favorites Only", isOn: $viewModel.favoritesOnlyToggle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            if viewModel.tipsCollection.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
                    Text("No results found")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                ForEach(viewModel.tipsCollection) { tip in
                    NavigationLink(destination: TipDetailZephyrView(tipId: tip.id)) {
                        TipCardZephyr(tip: tip)
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
}

struct VehicleButtonZephyr: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(12)
        }
    }
}

struct ScenarioFilterZephyr: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(20)
        }
    }
}

struct TipCardZephyr: View {
    let tip: VortexFuelTipNexusModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tip.headerTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.titleZephyr)
                    .lineLimit(2)
                
                Spacer()
                
                if tip.favoriteStatus {
                    Image(systemName: "heart.fill")
                        .foregroundColor(ZephyrColorScheme.selectedFilterZephyr)
                        .font(.system(size: 16))
                }
            }
            
            Text(tip.contextScenario)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(ZephyrColorScheme.categoryZephyr)
            
            Text(tip.contentDescription)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                .lineLimit(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: ZephyrColorScheme.shadowZephyr, radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}



