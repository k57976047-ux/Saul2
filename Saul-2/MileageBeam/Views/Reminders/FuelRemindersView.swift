import SwiftUI

struct FuelRemindersView: View {
    @State private var reminders: [FuelReminder] = sampleReminders
    @State private var showAddReminder = false
    
    var activeReminders: [FuelReminder] {
        reminders.filter { $0.isEnabled }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        summarySection
                        remindersList
                    }
                    .padding()
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddReminder = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(ZephyrColorScheme.titleZephyr)
                    }
                }
            }
            .sheet(isPresented: $showAddReminder) {
                AddReminderView(onSave: { newReminder in
                    reminders.append(newReminder)
                })
            }
        }
    }
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 30) {
                ReminderStatCard(
                    title: "Active",
                    value: "\(activeReminders.count)",
                    icon: "bell.fill",
                    color: ZephyrColorScheme.selectedFilterZephyr
                )
                
                ReminderStatCard(
                    title: "Total",
                    value: "\(reminders.count)",
                    icon: "list.bullet",
                    color: ZephyrColorScheme.titleZephyr
                )
            }
        }
    }
    
    private var remindersList: some View {
        VStack(spacing: 16) {
            if reminders.isEmpty {
                EmptyRemindersView()
            } else {
                ForEach(reminders) { reminder in
                    ReminderCard(reminder: reminder, onToggle: {
                        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                            reminders[index].isEnabled.toggle()
                        }
                    })
                }
            }
        }
    }
}

struct FuelReminder: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var icon: String
    var frequency: ReminderFrequency
    var isEnabled: Bool
    var lastTriggered: Date?
}

enum ReminderFrequency: Equatable {
    case daily, weekly, monthly, custom(Int)
    
    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom(let days): return "Every \(days) days"
        }
    }
}

struct ReminderStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
}

struct ReminderCard: View {
    let reminder: FuelReminder
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(reminder.isEnabled ? reminder.frequency.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: reminder.icon)
                    .font(.system(size: 28))
                    .foregroundColor(reminder.isEnabled ? reminder.frequency.color : Color.gray.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(reminder.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(reminder.isEnabled ? ZephyrColorScheme.primaryTextZephyr : ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
                
                Text(reminder.description)
                    .font(.system(size: 14))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Label(reminder.frequency.displayName, systemImage: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(reminder.frequency.color)
                    
                    if let lastTriggered = reminder.lastTriggered {
                        Text("Last: \(lastTriggered, style: .relative)")
                            .font(.system(size: 11))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding()
        .background(reminder.isEnabled ? ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.9) : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.5))
        .cornerRadius(16)
    }
}

extension ReminderFrequency {
    var color: Color {
        switch self {
        case .daily: return ZephyrColorScheme.selectedFilterZephyr
        case .weekly: return ZephyrColorScheme.titleZephyr
        case .monthly: return ZephyrColorScheme.categoryZephyr
        case .custom: return ZephyrColorScheme.buttonZephyr
        }
    }
}

struct EmptyRemindersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
            
            Text("No Reminders")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text("Create reminders to help you maintain your vehicle and save fuel")
                .font(.system(size: 16))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (FuelReminder) -> Void
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedIcon: String = "fuelpump.fill"
    @State private var frequency: ReminderFrequency = .weekly
    @State private var customDays: String = "7"
    
    let availableIcons = ["fuelpump.fill", "tirepressure", "wrench.fill", "oilcan.fill", "sparkles", "calendar", "bell.fill"]
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        titleField
                        descriptionField
                        iconSelector
                        frequencySelector
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            TextField("e.g., Check Tire Pressure", text: $title)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
    
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            TextField("Optional description", text: $description, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
    
    private var iconSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Image(systemName: icon)
                                .font(.system(size: 32))
                                .foregroundColor(selectedIcon == icon ? .black : ZephyrColorScheme.primaryTextZephyr)
                                .frame(width: 60, height: 60)
                                .background(selectedIcon == icon ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
    
    private var frequencySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Frequency")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            VStack(spacing: 12) {
                FrequencyButton(title: "Daily", isSelected: frequency == .daily) {
                    frequency = .daily
                }
                
                FrequencyButton(title: "Weekly", isSelected: frequency == .weekly) {
                    frequency = .weekly
                }
                
                FrequencyButton(title: "Monthly", isSelected: frequency == .monthly) {
                    frequency = .monthly
                }
                
                HStack {
                    TextField("Custom days", text: $customDays)
                        .keyboardType(.numberPad)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button("Set") {
                        if let days = Int(customDays), days > 0 {
                            frequency = .custom(days)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: saveReminder) {
            Text("Create Reminder")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ZephyrColorScheme.buttonZephyr)
                .cornerRadius(16)
        }
        .disabled(title.isEmpty)
        .opacity(title.isEmpty ? 0.6 : 1.0)
    }
    
    private func saveReminder() {
        let reminder = FuelReminder(
            id: UUID(),
            title: title,
            description: description,
            icon: selectedIcon,
            frequency: frequency,
            isEnabled: true,
            lastTriggered: nil
        )
        
        onSave(reminder)
        dismiss()
    }
}

struct FrequencyButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .black : ZephyrColorScheme.primaryTextZephyr)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? ZephyrColorScheme.activeFilterZephyr : ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.6))
                .cornerRadius(12)
        }
    }
}

let sampleReminders: [FuelReminder] = [
    FuelReminder(id: UUID(), title: "Check Tire Pressure", description: "Maintain optimal pressure for better fuel efficiency", icon: "tirepressure", frequency: .weekly, isEnabled: true, lastTriggered: Date().addingTimeInterval(-86400 * 2)),
    FuelReminder(id: UUID(), title: "Oil Change", description: "Regular maintenance improves engine efficiency", icon: "oilcan.fill", frequency: .monthly, isEnabled: true, lastTriggered: nil),
    FuelReminder(id: UUID(), title: "Air Filter Check", description: "Clean filter reduces fuel consumption", icon: "windshield.front", frequency: .monthly, isEnabled: false, lastTriggered: nil)
]

