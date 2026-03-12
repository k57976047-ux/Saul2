import Foundation

class PulseOnboardingMatrixViewModel: ObservableObject {
    @Published var activePageIndex: Int = 0
    
    func finalizeOnboardingFlow() {
        UserDefaults.standard.set(true, forKey: "onboardingFlowCompleted")
    }
    
    static func checkOnboardingRequired() -> Bool {
        return !UserDefaults.standard.bool(forKey: "onboardingFlowCompleted")
    }
}

