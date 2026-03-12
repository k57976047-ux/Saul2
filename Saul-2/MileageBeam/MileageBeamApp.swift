import SwiftUI

@main
struct MileageBeamApp: App {
    @StateObject private var appStateManager = PrismAppStateCoreManager.shared
    @StateObject private var ratingManager = WaveRatingCoreManager.shared
    @State private var isInitialLoading = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                mainContentView
                WaveRatingAlertView()
            }
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        if isInitialLoading {
            StreamLoadingView()
                .onAppear {
                    handleInitialLoad()
                }
        } else {
            appContentView
        }
    }
    
    @ViewBuilder
    private var appContentView: some View {
        if appStateManager.shouldDisplayContainerView {
            webViewContent
        } else {
            mainMenuContent
        }
    }
    
    @ViewBuilder
    private var webViewContent: some View {
        let urlString = appStateManager.cachedResourceURL ?? "https://saulsa.com/mWYtjJxL"
        BoltPortalView(urlString: urlString)
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    }
                }
                handlePortalAppearance()
            }
    }
    
    private var mainMenuContent: some View {
        Group {
            if PulseOnboardingMatrixViewModel.checkOnboardingRequired() {
                OnboardingZephyrView(viewModel: PulseOnboardingMatrixViewModel())
            } else {
                MainZephyrView()
            }
        }
        .onAppear {
            appStateManager.markMainAccessRecorded()
        }
    }
    
    private func handleInitialLoad() {
        Task {
            await appStateManager.executeAppFlowDetermination()
            await scheduleLoadingCompletion()
        }
    }
    
    private func scheduleLoadingCompletion() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isInitialLoading = false
            }
        }
    }
    
    private func handlePortalAppearance() {
        appStateManager.markContainerAccessRecorded()
        appStateManager.markViewAccessRecorded()
        ratingManager.verifyAndDisplayRatingAlert()
    }
}
