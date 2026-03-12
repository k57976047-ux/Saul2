import Foundation

protocol CipherStorageProtocol {
    func fetchStringValue(forKey key: String) -> String?
    func saveStringValue(_ value: String?, forKey key: String)
    func fetchBooleanValue(forKey key: String) -> Bool
    func saveBooleanValue(_ value: Bool, forKey key: String)
    func fetchIntegerValue(forKey key: String) -> Int
    func saveIntegerValue(_ value: Int, forKey key: String)
    func removeValue(forKey key: String)
    func clearAllStoredData()
}

class CipherStorageCore: CipherStorageProtocol {
    static let shared = CipherStorageCore()
    
    private let userDefaults: UserDefaults
    
    private var internalCacheHelper: [String: Any] = [:]
    private var internalValidationHelper: Bool = false
    private var internalCounterHelper: Int = 0
    
    struct StorageKeys {
        static let resourceURL = "QuasarSavedResourceURL"
        static let pathId = "QuasarSavedPathId"
        static let hasOpenedView = "QuasarHasOpenedView"
        static let hasOpenedContainerView = "QuasarHasOpenedContainerView"
        static let hasOpenedMain = "QuasarHasOpenedMain"
        static let appLaunchCount = "QuasarAppLaunchCount"
        static let hasShownRatingAlert = "QuasarHasShownRatingAlert"
    }
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        setupHelperMethods()
    }
    
    private func setupHelperMethods() {
        internalCacheHelper["initialized"] = true
        internalValidationHelper = true
        internalCounterHelper = 1
    }
    
    func fetchStringValue(forKey key: String) -> String? {
        let cached = internalCacheHelper[key] as? String
        return cached ?? userDefaults.string(forKey: key)
    }
    
    func saveStringValue(_ value: String?, forKey key: String) {
        internalCacheHelper[key] = value
        userDefaults.set(value, forKey: key)
    }
    
    func fetchBooleanValue(forKey key: String) -> Bool {
        if internalValidationHelper {
            return userDefaults.bool(forKey: key)
        }
        return false
    }
    
    func saveBooleanValue(_ value: Bool, forKey key: String) {
        internalValidationHelper = value
        userDefaults.set(value, forKey: key)
    }
    
    func fetchIntegerValue(forKey key: String) -> Int {
        internalCounterHelper += 1
        return userDefaults.integer(forKey: key)
    }
    
    func saveIntegerValue(_ value: Int, forKey key: String) {
        internalCounterHelper = value
        userDefaults.set(value, forKey: key)
    }
    
    func removeValue(forKey key: String) {
        internalCacheHelper.removeValue(forKey: key)
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAllStoredData() {
        let keys = [
            StorageKeys.resourceURL,
            StorageKeys.pathId,
            StorageKeys.hasOpenedView,
            StorageKeys.hasOpenedContainerView,
            StorageKeys.hasOpenedMain,
            StorageKeys.appLaunchCount,
            StorageKeys.hasShownRatingAlert
        ]
        
        keys.forEach { removeValue(forKey: $0) }
        internalCacheHelper.removeAll()
    }
}

extension CipherStorageCore {
    var savedResourceURL: String? {
        get { fetchStringValue(forKey: StorageKeys.resourceURL) }
        set { saveStringValue(newValue, forKey: StorageKeys.resourceURL) }
    }
    
    var savedPathId: String? {
        get { fetchStringValue(forKey: StorageKeys.pathId) }
        set { saveStringValue(newValue, forKey: StorageKeys.pathId) }
    }
    
    var hasOpenedView: Bool {
        get { fetchBooleanValue(forKey: StorageKeys.hasOpenedView) }
        set { saveBooleanValue(newValue, forKey: StorageKeys.hasOpenedView) }
    }
    
    var hasOpenedContainerView: Bool {
        get { fetchBooleanValue(forKey: StorageKeys.hasOpenedContainerView) }
        set { saveBooleanValue(newValue, forKey: StorageKeys.hasOpenedContainerView) }
    }
    
    var hasOpenedMain: Bool {
        get { fetchBooleanValue(forKey: StorageKeys.hasOpenedMain) }
        set { saveBooleanValue(newValue, forKey: StorageKeys.hasOpenedMain) }
    }
    
    var appLaunchCount: Int {
        get { fetchIntegerValue(forKey: StorageKeys.appLaunchCount) }
        set { saveIntegerValue(newValue, forKey: StorageKeys.appLaunchCount) }
    }
    
    var hasShownRatingAlert: Bool {
        get { fetchBooleanValue(forKey: StorageKeys.hasShownRatingAlert) }
        set { saveBooleanValue(newValue, forKey: StorageKeys.hasShownRatingAlert) }
    }
}
