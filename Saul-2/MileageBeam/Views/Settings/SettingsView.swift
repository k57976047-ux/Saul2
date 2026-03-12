import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var darkModeEnabled: Bool = false
    @State private var unitSystem: UnitSystem = .metric
    @State private var selectedLanguage: String = "English"
    @State private var showAbout = false
    @State private var showPrivacy = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        preferencesSection
                        dataSection
                        aboutSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyPolicyView()
            }
        }
    }
    
    private var preferencesSection: some View {
        SettingsSection(title: "Preferences") {
            SettingsRow(
                icon: "bell.fill",
                title: "Notifications",
                trailing: {
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                }
            )
            
            SettingsRow(
                icon: "moon.fill",
                title: "Dark Mode",
                trailing: {
                    Toggle("", isOn: $darkModeEnabled)
                        .labelsHidden()
                }
            )
            
            SettingsRow(
                icon: "ruler.fill",
                title: "Unit System",
                trailing: {
                    Picker("", selection: $unitSystem) {
                        Text("Metric").tag(UnitSystem.metric)
                        Text("Imperial").tag(UnitSystem.imperial)
                    }
                    .pickerStyle(.menu)
                }
            )
            
            SettingsRow(
                icon: "globe",
                title: "Language",
                trailing: {
                    Picker("", selection: $selectedLanguage) {
                        Text("English").tag("English")
                        Text("Spanish").tag("Spanish")
                        Text("French").tag("French")
                    }
                    .pickerStyle(.menu)
                }
            )
        }
    }
    
    private var dataSection: some View {
        SettingsSection(title: "Data") {
            SettingsRow(
                icon: "arrow.down.circle.fill",
                title: "Export Data",
                action: {
                }
            )
            
            SettingsRow(
                icon: "arrow.up.circle.fill",
                title: "Import Data",
                action: {
                }
            )
            
            SettingsRow(
                icon: "trash.fill",
                title: "Clear All Data",
                titleColor: .red,
                action: {
                }
            )
        }
    }
    
    private var aboutSection: some View {
        SettingsSection(title: "About") {
            SettingsRow(
                icon: "info.circle.fill",
                title: "About MileageBeam",
                action: {
                    showAbout = true
                }
            )
            
            SettingsRow(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                action: {
                    showPrivacy = true
                }
            )
            
            SettingsRow(
                icon: "star.fill",
                title: "Rate App",
                action: {
                }
            )
            
            SettingsRow(
                icon: "envelope.fill",
                title: "Contact Support",
                action: {
                }
            )
            
            VStack(spacing: 8) {
                Text("Version 1.0.0")
                    .font(.system(size: 14))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                
                Text("© 2025 MileageBeam")
                    .font(.system(size: 12))
                    .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}

enum UnitSystem {
    case metric, imperial
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                content
            }
            .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
            .cornerRadius(16)
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    var titleColor: Color = ZephyrColorScheme.primaryTextZephyr
    let trailing: Trailing
    var action: (() -> Void)? = nil
    
    init(icon: String, title: String, titleColor: Color = ZephyrColorScheme.primaryTextZephyr, @ViewBuilder trailing: () -> Trailing, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.titleColor = titleColor
        self.trailing = trailing()
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(titleColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(titleColor)
                
                Spacer()
                
                trailing
            }
            .padding()
        }
        .disabled(action == nil && trailing is EmptyView)
    }
}

extension SettingsRow where Trailing == EmptyView {
    init(icon: String, title: String, titleColor: Color = ZephyrColorScheme.primaryTextZephyr, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.titleColor = titleColor
        self.trailing = EmptyView()
        self.action = action
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        appIconSection
                        descriptionSection
                        featuresSection
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var appIconSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "fuelpump.fill")
                .font(.system(size: 80))
                .foregroundColor(ZephyrColorScheme.titleZephyr)
            
            Text("MileageBeam")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text("Your Fuel Efficiency Companion")
                .font(.system(size: 18))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text("MileageBeam helps you save fuel and reduce your carbon footprint by providing personalized tips and tracking your fuel consumption. Whether you drive a car or ride a motorcycle, we have tips for every scenario.")
                .font(.system(size: 16))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.8))
                .lineSpacing(4)
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Features")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            FeatureRow(icon: "lightbulb.fill", text: "100+ fuel saving tips")
            FeatureRow(icon: "car.fill", text: "Tips for cars and motorcycles")
            FeatureRow(icon: "chart.bar.fill", text: "Track your fuel consumption")
            FeatureRow(icon: "trophy.fill", text: "Achievements and progress")
            FeatureRow(icon: "calculator.fill", text: "Savings calculator")
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(16)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ZephyrColorScheme.titleZephyr)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                ZephyrColorScheme.gradientBackgroundZephyr
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
                        
                        Text("Last Updated: December 2025")
                            .font(.system(size: 14))
                            .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.6))
                        
                        PrivacySection(title: "Data Collection", content: "We collect minimal data necessary to provide our services. This includes trip data you voluntarily enter and app usage statistics.")
                        
                        PrivacySection(title: "Data Usage", content: "Your data is used solely to improve your fuel efficiency experience. We do not sell your personal information to third parties.")
                        
                        PrivacySection(title: "Data Storage", content: "All data is stored locally on your device. You can export or delete your data at any time through the Settings menu.")
                        
                        PrivacySection(title: "Third-Party Services", content: "We use AppsFlyer for analytics purposes. Please refer to their privacy policy for more information.")
                        
                        PrivacySection(title: "Your Rights", content: "You have the right to access, modify, or delete your personal data at any time through the app settings.")
                    }
                    .padding()
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(ZephyrColorScheme.primaryTextZephyr.opacity(0.8))
                .lineSpacing(4)
        }
        .padding()
        .background(ZephyrColorScheme.secondaryBackgroundZephyr.opacity(0.8))
        .cornerRadius(12)
    }
}

