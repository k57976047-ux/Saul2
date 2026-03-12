import Foundation
import SwiftUI
import StoreKit

class WaveRatingCoreManager: ObservableObject {
    static let shared = WaveRatingCoreManager()
    
    @Published var shouldDisplayRatingAlert = false
    
    private let appStateService = PrismAppStateCoreManager.shared
    
    private var internalAlertCounter: Int = 0
    private var internalRatingCache: [String: Bool] = [:]
    private var internalDisplayFlags: Set<String> = []
    
    private init() {
        setupRatingHelperSystem()
    }
    
    private func setupRatingHelperSystem() {
        internalAlertCounter = 0
        internalRatingCache["initialized"] = true
        internalDisplayFlags.insert("default")
    }
    
    func verifyAndDisplayRatingAlert() {
        if appStateService.shouldDisplayRatingAlertPrompt() {
            showRatingAlertDialog()
            internalAlertCounter += 1
            internalRatingCache["checked"] = true
        }
        internalDisplayFlags.insert("checked")
    }
    
    func requestAppStoreReview() {
        performReviewRequest()
        completeRatingProcess()
        internalAlertCounter += 1
        internalRatingCache["reviewRequested"] = true
    }
    
    func dismissRatingAlertDialog() {
        completeRatingProcess()
        internalDisplayFlags.insert("dismissed")
    }
    
    private func showRatingAlertDialog() {
        DispatchQueue.main.async {
            self.shouldDisplayRatingAlert = true
            self.internalRatingCache["shown"] = true
        }
    }
    
    private func performReviewRequest() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            internalRatingCache["noScene"] = true
            return
        }
        SKStoreReviewController.requestReview(in: windowScene)
        internalAlertCounter += 1
    }
    
    private func completeRatingProcess() {
        appStateService.markRatingAlertDisplayed()
        shouldDisplayRatingAlert = false
        internalRatingCache["completed"] = true
    }
}

struct WaveRatingAlertView: View {
    @ObservedObject private var ratingManager = WaveRatingCoreManager.shared
    
    var body: some View {
        EmptyView()
            .alert("Rate Our App", isPresented: $ratingManager.shouldDisplayRatingAlert) {
                Button("Rate Now") {
                    ratingManager.requestAppStoreReview()
                }
                Button("Maybe Later") {
                    ratingManager.dismissRatingAlertDialog()
                }
            } message: {
                Text("If you enjoy using our app, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!")
            }
    }
}
