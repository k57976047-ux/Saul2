import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct StatisticsZephyrView: View {
    @StateObject private var viewModel = FluxStatisticsVectorViewModel(dataSource: BoltFuelTipRepository())
    @Environment(\.dismiss) var dismiss
    @State private var selectedVehicleZephyr: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        vehicleDistributionChartZephyr
                        scenarioDistributionChartZephyr
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ZephyrColorScheme.titleZephyr)
                }
            }
            .onAppear {
                viewModel.refreshStatisticsData()
            }
        }
    }
    
    private var vehicleDistributionChartZephyr: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tips by Vehicle Type")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            #if canImport(Charts)
            if #available(iOS 17.0, *) {
                Chart {
                    ForEach(Array(viewModel.vehicleDistributionMap.keys.sorted()), id: \.self) { key in
                        SectorMark(
                            angle: .value("Count", viewModel.vehicleDistributionMap[key] ?? 0),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(key == "Car" ? ZephyrColorScheme.titleZephyr : ZephyrColorScheme.selectedFilterZephyr)
                        .annotation(position: .overlay) {
                            Text("\(viewModel.vehicleDistributionMap[key] ?? 0)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(height: 250)
                .padding()
                .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.7))
                .cornerRadius(16)
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(viewModel.vehicleDistributionMap.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                            Spacer()
                            Text("\(viewModel.vehicleDistributionMap[key] ?? 0)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(key == "Car" ? ZephyrColorScheme.titleZephyr : ZephyrColorScheme.selectedFilterZephyr)
                        }
                        .padding()
                        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.7))
                        .cornerRadius(12)
                    }
                }
            }
            #else
            VStack(spacing: 16) {
                ForEach(Array(viewModel.vehicleDistributionZephyr.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                        Spacer()
                        Text("\(viewModel.vehicleDistributionZephyr[key] ?? 0)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(key == "Car" ? ZephyrColorScheme.titleZephyr : ZephyrColorScheme.selectedFilterZephyr)
                    }
                    .padding()
                    .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.7))
                    .cornerRadius(12)
                }
            }
            #endif
        }
    }
    
    private var scenarioDistributionChartZephyr: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tips by Scenario")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            VStack(spacing: 12) {
                ForEach(Array(viewModel.scenarioDistributionMap.keys.sorted()), id: \.self) { key in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                                .lineLimit(1)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(viewModel.scenarioDistributionMap[key] ?? 0) tips")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.8))
                                if (viewModel.favoriteScenarioMap[key] ?? 0) > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 11))
                                        Text("\(viewModel.favoriteScenarioMap[key] ?? 0) fav")
                                            .font(.system(size: 13, weight: .regular))
                                    }
                                    .foregroundColor(ZephyrColorScheme.selectedFilterZephyr)
                                }
                            }
                        }
                        Spacer(minLength: 8)
                        Text("\(viewModel.scenarioDistributionMap[key] ?? 0)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(ZephyrColorScheme.titleZephyr)
                            .lineLimit(1)
                    }
                    .padding(14)
                    .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.9))
                    .cornerRadius(12)
                }
            }
            
            #if canImport(Charts)
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(Array(viewModel.scenarioDistributionMap.keys.sorted()), id: \.self) { key in
                        BarMark(
                            x: .value("Scenario", key),
                            y: .value("Count", viewModel.scenarioDistributionMap[key] ?? 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ZephyrColorScheme.titleZephyr, ZephyrColorScheme.categoryZephyr],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .annotation(position: .top) {
                            Text("\(viewModel.scenarioDistributionMap[key] ?? 0)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ZephyrColorScheme.titleZephyr)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let scenario = value.as(String.self) {
                                Text(scenarioShortName(scenario))
                                    .foregroundStyle(ZephyrColorScheme.primaryTextZephyr)
                                    .font(.system(size: 10, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(ZephyrColorScheme.primaryTextZephyr)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .frame(height: 380)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.9))
                .cornerRadius(16)
            }
            #endif
        }
    }
    
    private func scenarioShortName(_ scenario: String) -> String {
        switch scenario {
        case "All Scenarios":
            return "All"
        case "Highway":
            return "Hwy"
        case "Traffic":
            return "Traffic"
        case "Weather":
            return "Weather"
        case "Cold":
            return "Cold"
        case "Hot":
            return "Hot"
        case "City":
            return "City"
        default:
            return scenario
        }
    }
}

