import SwiftUI

struct QuickTipsView: View {
    @State private var selectedScenario: String = "All"
    @State private var quickTips: [QuickTip] = sampleQuickTips
    
    var filteredTips: [QuickTip] {
        if selectedScenario == "All" {
            return quickTips
        }
        return quickTips.filter { $0.scenario == selectedScenario }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    scenarioSelector
                    tipsGrid
                }
            }
            .navigationTitle("Quick Tips")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var scenarioSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ScenarioChip(title: "All", isSelected: selectedScenario == "All") {
                    selectedScenario = "All"
                }
                
                ForEach(["City", "Highway", "Traffic", "Weather"], id: \.self) { scenario in
                    ScenarioChip(title: scenario, isSelected: selectedScenario == scenario) {
                        selectedScenario = scenario
                    }
                }
            }
            .padding()
        }
    }
    
    private var tipsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredTips) { tip in
                    QuickTipCard(tip: tip)
                }
            }
            .padding()
        }
    }
}

struct QuickTip: Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let scenario: String
    let shortDescription: String
    let impact: TipImpact
    let difficulty: TipDifficulty
}

enum TipImpact {
    case high, medium, low
    
    var color: Color {
        switch self {
        case .high: return ZephyrColorScheme.selectedFilterZephyr
        case .medium: return ZephyrColorScheme.titleZephyr
        case .low: return ZephyrColorScheme.categoryZephyr
        }
    }
    
    var label: String {
        switch self {
        case .high: return "High Impact"
        case .medium: return "Medium Impact"
        case .low: return "Low Impact"
        }
    }
}

enum TipDifficulty {
    case easy, medium, hard
    
    var label: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

struct QuickTipCard: View {
    let tip: QuickTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(tip.impact.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: tip.icon)
                        .font(.system(size: 24))
                        .foregroundColor(tip.impact.color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(tip.impact.label)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(tip.impact.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tip.impact.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(tip.difficulty.label)
                        .font(.system(size: 10))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                }
            }
            
            Text(tip.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                .lineLimit(2)
            
            Text(tip.shortDescription)
                .font(.system(size: 13))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                .lineLimit(3)
            
            Text(tip.scenario)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ZephyrColorScheme.categoryZephyr)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: ZephyrColorScheme.shadowZephyr, radius: 4, x: 0, y: 2)
    }
}

struct ScenarioChip: View {
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

let sampleQuickTips: [QuickTip] = [
    QuickTip(id: UUID(), title: "Maintain Tire Pressure", icon: "tirepressure", scenario: "All", shortDescription: "Check weekly for optimal efficiency", impact: .high, difficulty: .easy),
    QuickTip(id: UUID(), title: "Smooth Acceleration", icon: "speedometer", scenario: "City", shortDescription: "Avoid sudden starts to save fuel", impact: .high, difficulty: .easy),
    QuickTip(id: UUID(), title: "Use Cruise Control", icon: "road.lanes", scenario: "Highway", shortDescription: "Maintain constant speed on long trips", impact: .medium, difficulty: .easy),
    QuickTip(id: UUID(), title: "Remove Roof Racks", icon: "wind", scenario: "Highway", shortDescription: "Reduce aerodynamic drag significantly", impact: .medium, difficulty: .easy),
    QuickTip(id: UUID(), title: "Plan Routes", icon: "map.fill", scenario: "Traffic", shortDescription: "Avoid traffic jams and short trips", impact: .high, difficulty: .medium),
    QuickTip(id: UUID(), title: "Check Air Filter", icon: "windshield.front", scenario: "All", shortDescription: "Replace when dirty for better efficiency", impact: .medium, difficulty: .medium),
    QuickTip(id: UUID(), title: "Warm Up Efficiently", icon: "thermometer", scenario: "Cold", shortDescription: "Drive gently instead of idling", impact: .medium, difficulty: .easy),
    QuickTip(id: UUID(), title: "Use AC Wisely", icon: "snowflake", scenario: "Hot", shortDescription: "Use recirculation mode above 80 km/h", impact: .low, difficulty: .easy)
]

