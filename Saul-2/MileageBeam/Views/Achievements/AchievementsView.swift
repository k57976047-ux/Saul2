import SwiftUI

struct AchievementsView: View {
    @State private var achievements: [Achievement] = sampleAchievements
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
    
    var progressPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        progressHeader
                        achievementsGrid
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(ZephyrColorScheme.titleZephyr, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: progressPercentage)
                
                VStack(spacing: 4) {
                    Text("\(unlockedCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(ZephyrColorScheme.titleZephyr)
                    Text("of \(totalCount)")
                        .font(.system(size: 14))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                }
            }
            
            Text("\(Int(progressPercentage * 100))% Complete")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(20)
    }
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(achievements) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
    }
}

struct Achievement: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let progress: Double
    let target: Double
    let category: AchievementCategory
}

enum AchievementCategory {
    case tips, trips, savings, efficiency
    
    var color: Color {
        switch self {
        case .tips: return ZephyrColorScheme.titleZephyr
        case .trips: return ZephyrColorScheme.categoryZephyr
        case .savings: return ZephyrColorScheme.selectedFilterZephyr
        case .efficiency: return ZephyrColorScheme.buttonZephyr
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.category.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundColor(achievement.isUnlocked ? achievement.category.color : Color.gray.opacity(0.5))
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? ZephyrColorScheme.primaryTextZephyr : ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.system(size: 12))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    ProgressBar(progress: achievement.progress / achievement.target)
                    Text("\(Int(achievement.progress))/\(Int(achievement.target))")
                        .font(.system(size: 11))
                        .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(achievement.category.color)
                        Text("Unlocked")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(achievement.category.color)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(achievement.isUnlocked ? ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.9) : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isUnlocked ? achievement.category.color.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(ZephyrColorScheme.titleZephyr)
                    .frame(width: geometry.size.width * min(progress, 1.0), height: 4)
                    .cornerRadius(2)
            }
        }
        .frame(height: 4)
    }
}

let sampleAchievements: [Achievement] = [
    Achievement(id: UUID(), title: "First Steps", description: "Read 10 fuel saving tips", icon: "book.fill", isUnlocked: true, progress: 10, target: 10, category: .tips),
    Achievement(id: UUID(), title: "Road Warrior", description: "Record 25 trips", icon: "road.lanes", isUnlocked: false, progress: 18, target: 25, category: .trips),
    Achievement(id: UUID(), title: "Efficiency Master", description: "Achieve 5.0 L/100km average", icon: "chart.line.uptrend.xyaxis", isUnlocked: false, progress: 6.2, target: 5.0, category: .efficiency),
    Achievement(id: UUID(), title: "Money Saver", description: "Save $500 on fuel", icon: "dollarsign.circle.fill", isUnlocked: false, progress: 320, target: 500, category: .savings),
    Achievement(id: UUID(), title: "Tip Collector", description: "Favorite 20 tips", icon: "heart.fill", isUnlocked: false, progress: 12, target: 20, category: .tips),
    Achievement(id: UUID(), title: "Long Distance", description: "Travel 1000 km total", icon: "map.fill", isUnlocked: false, progress: 650, target: 1000, category: .trips)
]

