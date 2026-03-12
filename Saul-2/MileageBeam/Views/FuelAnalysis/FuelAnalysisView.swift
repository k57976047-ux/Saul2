import SwiftUI
import Charts

struct FuelAnalysisView: View {
    @State private var analysisData: FuelAnalysisData = sampleAnalysisData
    @State private var selectedTimeframe: Timeframe = .month
    @State private var selectedVehicle: String = "All"
    
    var filteredData: [ConsumptionDataPoint] {
        var data = analysisData.dataPoints
        
        if selectedVehicle != "All" {
            data = data.filter { $0.vehicleType == selectedVehicle }
        }
        
        return data.filter { point in
            let daysAgo = Calendar.current.dateComponents([.day], from: point.date, to: Date()).day ?? 0
            switch selectedTimeframe {
            case .week: return daysAgo <= 7
            case .month: return daysAgo <= 30
            case .year: return daysAgo <= 365
            }
        }
    }
    
    var averageConsumption: Double {
        guard !filteredData.isEmpty else { return 0 }
        let total = filteredData.reduce(0.0) { $0 + $1.consumption }
        return total / Double(filteredData.count)
    }
    
    var bestConsumption: Double {
        filteredData.map { $0.consumption }.min() ?? 0
    }
    
    var worstConsumption: Double {
        filteredData.map { $0.consumption }.max() ?? 0
    }
    
    var improvementPercentage: Double {
        guard worstConsumption > 0 else { return 0 }
        return ((worstConsumption - bestConsumption) / worstConsumption) * 100
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        timeframeSelector
                        vehicleSelector
                        summaryCards
                        consumptionChart
                        insightsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Fuel Analysis")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeframeSelector: some View {
        HStack(spacing: 12) {
            TimeframeButton(title: "Week", isSelected: selectedTimeframe == .week) {
                selectedTimeframe = .week
            }
            TimeframeButton(title: "Month", isSelected: selectedTimeframe == .month) {
                selectedTimeframe = .month
            }
            TimeframeButton(title: "Year", isSelected: selectedTimeframe == .year) {
                selectedTimeframe = .year
            }
        }
    }
    
    private var vehicleSelector: some View {
        HStack(spacing: 12) {
            VehicleFilterButton(title: "All", isSelected: selectedVehicle == "All") {
                selectedVehicle = "All"
            }
            VehicleFilterButton(title: "Car", isSelected: selectedVehicle == "Car") {
                selectedVehicle = "Car"
            }
            VehicleFilterButton(title: "Motorcycle", isSelected: selectedVehicle == "Motorcycle") {
                selectedVehicle = "Motorcycle"
            }
        }
    }
    
    private var summaryCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Average",
                    value: String(format: "%.2f", averageConsumption),
                    unit: "L/100km",
                    icon: "chart.bar.fill",
                    color: ZephyrColorScheme.titleZephyr
                )
                
                SummaryCard(
                    title: "Best",
                    value: String(format: "%.2f", bestConsumption),
                    unit: "L/100km",
                    icon: "trophy.fill",
                    color: ZephyrColorScheme.selectedFilterZephyr
                )
            }
            
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Worst",
                    value: String(format: "%.2f", worstConsumption),
                    unit: "L/100km",
                    icon: "exclamationmark.triangle.fill",
                    color: ZephyrColorScheme.categoryZephyr
                )
                
                SummaryCard(
                    title: "Improvement",
                    value: String(format: "%.1f", improvementPercentage),
                    unit: "%",
                    icon: "arrow.down.circle.fill",
                    color: ZephyrColorScheme.buttonZephyr
                )
            }
        }
    }
    
    private var consumptionChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consumption Trend")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            #if canImport(Charts)
            if #available(iOS 16.0, *) {
                Chart(filteredData) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Consumption", point.consumption)
                    )
                    .foregroundStyle(ZephyrColorScheme.titleZephyr)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Consumption", point.consumption)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ZephyrColorScheme.titleZephyr.opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 250)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel(format: .dateTime.month().day())
                            .foregroundStyle(ZephyrColorScheme.primaryTextZephyr)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(ZephyrColorScheme.primaryTextZephyr)
                    }
                }
                .padding()
                .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
                .cornerRadius(16)
            } else {
                fallbackChart
            }
            #else
            fallbackChart
            #endif
        }
    }
    
    private var fallbackChart: some View {
        VStack(spacing: 12) {
            ForEach(filteredData.prefix(10)) { point in
                HStack {
                    Text(point.date, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                    
                    Spacer()
                    
                    Text(String(format: "%.2f L/100km", point.consumption))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            InsightCard(
                icon: "arrow.down.circle.fill",
                title: "Efficiency Trend",
                description: improvementPercentage > 0 ? "Your fuel efficiency has improved by \(String(format: "%.1f", improvementPercentage))%" : "Keep tracking to see your improvement",
                color: improvementPercentage > 0 ? ZephyrColorScheme.selectedFilterZephyr : ZephyrColorScheme.categoryZephyr
            )
            
            InsightCard(
                icon: "calendar",
                title: "Best Day",
                description: bestDayDescription,
                color: ZephyrColorScheme.titleZephyr
            )
            
            InsightCard(
                icon: "lightbulb.fill",
                title: "Recommendation",
                description: recommendationText,
                color: ZephyrColorScheme.buttonZephyr
            )
        }
    }
    
    private var bestDayDescription: String {
        guard let bestDay = filteredData.min(by: { $0.consumption < $1.consumption }) else {
            return "Not enough data"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Your most efficient day was \(formatter.string(from: bestDay.date)) with \(String(format: "%.2f", bestDay.consumption)) L/100km"
    }
    
    private var recommendationText: String {
        if averageConsumption > 8.0 {
            return "Try maintaining optimal speed and checking tire pressure to improve efficiency"
        } else if averageConsumption > 6.0 {
            return "Good efficiency! Focus on smooth acceleration and avoiding unnecessary idling"
        } else {
            return "Excellent efficiency! Keep up the great driving habits"
        }
    }
}

enum Timeframe {
    case week, month, year
}

struct FuelAnalysisData {
    let dataPoints: [ConsumptionDataPoint]
}

struct ConsumptionDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let consumption: Double
    let vehicleType: String
    let distance: Double
}

struct TimeframeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(12)
        }
    }
}

struct VehicleFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(20)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
            }
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
}

let sampleAnalysisData = FuelAnalysisData(dataPoints: [
    ConsumptionDataPoint(id: UUID(), date: Date().addingTimeInterval(-86400 * 30), consumption: 8.5, vehicleType: "Car", distance: 45),
    ConsumptionDataPoint(id: UUID(), date: Date().addingTimeInterval(-86400 * 25), consumption: 7.8, vehicleType: "Car", distance: 120),
    ConsumptionDataPoint(id: UUID(), date: Date().addingTimeInterval(-86400 * 20), consumption: 7.2, vehicleType: "Car", distance: 60),
    ConsumptionDataPoint(id: UUID(), date: Date().addingTimeInterval(-86400 * 15), consumption: 6.9, vehicleType: "Car", distance: 90),
    ConsumptionDataPoint(id: UUID(), date: Date().addingTimeInterval(-86400 * 10), consumption: 6.5, vehicleType: "Car", distance: 75),
    ConsumptionDataPoint(id: UUID(), date: Date().addingTimeInterval(-86400 * 5), consumption: 6.1, vehicleType: "Car", distance: 50),
    ConsumptionDataPoint(id: UUID(), date: Date(), consumption: 5.8, vehicleType: "Car", distance: 80)
])

