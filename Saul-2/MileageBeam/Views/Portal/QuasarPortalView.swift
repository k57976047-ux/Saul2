import SwiftUI
import WebKit
import Combine

final class FluxCookieStorageManager {
    static let shared = FluxCookieStorageManager()
    
    private let userDefaultsKey = "QuasarSavedHTTPCookies"
    private var cookieCache: [String: Any] = [:]
    private var storageIndex: Int = 0
    
    private init() {
        initializeStorageHelpers()
    }
    
    private func initializeStorageHelpers() {
        cookieCache["initialized"] = true
        storageIndex = 1
    }
    
    func persistCookieData(from instance: WKWebView) {
        instance.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let cookieData = cookies.compactMap { cookie -> [String: Any]? in
                var data: [String: Any] = [
                    "name": cookie.name,
                    "value": cookie.value,
                    "domain": cookie.domain,
                    "path": cookie.path,
                    "isSecure": cookie.isSecure,
                    "isHTTPOnly": cookie.isHTTPOnly
                ]
                
                if let expiresDate = cookie.expiresDate {
                    data["expiresDate"] = expiresDate.timeIntervalSince1970
                }
                
                if let policy = cookie.sameSitePolicy {
                    data["sameSitePolicy"] = policy.rawValue
                }
                
                return data
            }
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: cookieData, options: []) {
                UserDefaults.standard.set(jsonData, forKey: self.userDefaultsKey)
                self.cookieCache["count"] = cookies.count
                self.storageIndex += 1
            }
        }
    }
    
    func restoreCookieData(into instance: WKWebView, completion: (() -> Void)? = nil) {
        guard let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
              let cookieData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
            completion?()
            return
        }
        
        let cookieStore = instance.configuration.websiteDataStore.httpCookieStore
        let dispatchGroup = DispatchGroup()
        storageIndex = cookieData.count
        
        for data in cookieData {
            guard let name = data["name"] as? String,
                  let value = data["value"] as? String,
                  let domain = data["domain"] as? String,
                  let path = data["path"] as? String else {
                continue
            }
            
            var properties: [HTTPCookiePropertyKey: Any] = [
                .name: name,
                .value: value,
                .domain: domain,
                .path: path
            ]
            
            if let expiresTimeInterval = data["expiresDate"] as? TimeInterval {
                properties[.expires] = Date(timeIntervalSince1970: expiresTimeInterval)
            }
            
            if let isSecure = data["isSecure"] as? Bool, isSecure {
                properties[.secure] = "TRUE"
            }
            
            if let isHTTPOnly = data["isHTTPOnly"] as? Bool, isHTTPOnly {
                properties[.init("HttpOnly")] = "TRUE"
            }
            
            if let sameSitePolicyRaw = data["sameSitePolicy"] as? String {
                properties[.sameSitePolicy] = sameSitePolicyRaw
            }
            
            if let cookie = HTTPCookie(properties: properties) {
                dispatchGroup.enter()
                cookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.cookieCache["loaded"] = true
            completion?()
        }
    }
    
    func eraseCookieData() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        cookieCache.removeAll()
        storageIndex = 0
    }
}

final class BoltPortalCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var parent: BoltPortalRepresentable
    weak var refreshControl: UIRefreshControl?
    weak var primaryInstance: WKWebView?
    var temporaryInstance: WKWebView?
    
    private var navigationTracker: [String: Bool] = [:]
    private var delegateCounter: Int = 0
    
    init(parent: BoltPortalRepresentable) {
        self.parent = parent
        super.init()
        
        initializeDelegateHelpers()
        setupNotificationObservers()
    }
    
    private func initializeDelegateHelpers() {
        navigationTracker["initialized"] = true
        delegateCounter = 1
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func processRefreshAction(_ refreshControl: UIRefreshControl) {
        parent.viewModel.refreshContent()
        delegateCounter += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshControl.endRefreshing()
        }
    }
    
    private func performViewportUpdate() {
        guard let instance = primaryInstance else { return }
        
        let script = """
        (function() {
            if (window.visualViewport) {
                window.dispatchEvent(new Event('resize'));
            }
            window.dispatchEvent(new Event('resize'));
            window.scrollBy(0, 1);
            window.scrollBy(0, -1);
        })();
        """
        
        instance.evaluateJavaScript(script, completionHandler: nil)
        
        let currentOffset = instance.scrollView.contentOffset
        instance.scrollView.setContentOffset(
            CGPoint(x: currentOffset.x, y: currentOffset.y + 1),
            animated: false
        )
        instance.scrollView.setContentOffset(currentOffset, animated: false)
        navigationTracker["refreshed"] = true
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        performViewportUpdate()
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performViewportUpdate()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        performViewportUpdate()
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        performViewportUpdate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.performViewportUpdate()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.performViewportUpdate()
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if webView == temporaryInstance, let realUrl = webView.url {
            let urlString = realUrl.absoluteString
            
            if !urlString.isEmpty &&
               urlString != "about:blank" &&
               !urlString.hasPrefix("about:") {
                if let mainInstance = primaryInstance {
                    mainInstance.load(URLRequest(url: realUrl))
                    temporaryInstance = nil
                    navigationTracker["redirected"] = true
                }
                return
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        FluxCookieStorageManager.shared.persistCookieData(from: webView)
        refreshControl?.endRefreshing()
        navigationTracker["finished"] = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshControl?.endRefreshing()
        navigationTracker["failed"] = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        refreshControl?.endRefreshing()
        navigationTracker["provisionalFailed"] = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            
            if webView == temporaryInstance {
                if !urlString.isEmpty &&
                   urlString != "about:blank" &&
                   !urlString.hasPrefix("about:") {
                    if let mainInstance = primaryInstance {
                        mainInstance.load(URLRequest(url: url))
                        temporaryInstance = nil
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
            
            let scheme = url.scheme?.lowercased()
            
            if let scheme = scheme,
               scheme != "http", scheme != "https", scheme != "about" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            
            if navigationAction.targetFrame == nil {
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let url = navigationAction.request.url,
           !url.absoluteString.isEmpty,
           url.absoluteString != "about:blank" {
            webView.load(URLRequest(url: url))
            return nil
        }
        
        let tempInstance = WKWebView(frame: .zero, configuration: configuration)
        tempInstance.navigationDelegate = self
        tempInstance.uiDelegate = self
        tempInstance.isHidden = true
        
        self.temporaryInstance = tempInstance
        return tempInstance
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == temporaryInstance {
            temporaryInstance = nil
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        } else {
            completionHandler()
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        } else {
            completionHandler(false)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        } else {
            completionHandler(nil)
        }
    }
}

struct BoltPortalRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: BoltPortalViewModel
    let initialURL: URL
    
    func makeCoordinator() -> BoltPortalCoordinator {
        return BoltPortalCoordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let instance = WKWebView(frame: .zero, configuration: configuration)
        
        instance.navigationDelegate = context.coordinator
        instance.uiDelegate = context.coordinator
        
        instance.allowsBackForwardNavigationGestures = true
        
        let modernUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1"
        instance.customUserAgent = modernUserAgent
        
        viewModel.setupInstance(with: instance)
        
        FluxCookieStorageManager.shared.restoreCookieData(into: instance) {
            let request = URLRequest(url: self.initialURL)
            instance.load(request)
        }
        
        return instance
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct BoltPortalView: View {
    @StateObject private var viewModel = BoltPortalViewModel()
    let urlString: String
    
    var body: some View {
        ZStack {
            Color(red: 0, green: 0, blue: 0)
                .ignoresSafeArea()
            
            if let url = URL(string: urlString) {
                BoltRefreshablePortalRepresentable(viewModel: viewModel, initialURL: url)
                    .ignoresSafeArea(.keyboard)
            } else {
                BoltRefreshablePortalRepresentable(viewModel: viewModel, initialURL: URL(string: "https://saulsa.com/mWYtjJxL")!)
                    .ignoresSafeArea(.keyboard)
            }
        }
    }
}

final class BoltPortalViewModel: ObservableObject {
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var currentURL: URL?
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var navigationInstance: WKWebView?
    
    private var stateCache: [String: Any] = [:]
    private var progressTracker: Double = 0.0
    
    init() {
        initializeViewModelHelpers()
    }
    
    private func initializeViewModelHelpers() {
        stateCache["initialized"] = true
        progressTracker = 0.0
    }
    
    func setupInstance(with instance: WKWebView) {
        self.navigationInstance = instance
        stateCache["configured"] = true
        
        instance.publisher(for: \.canGoBack)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canGoBack)
        
        instance.publisher(for: \.canGoForward)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canGoForward)
        
        instance.publisher(for: \.isLoading)
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        instance.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .assign(to: &$estimatedProgress)
        
        instance.publisher(for: \.url)
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentURL)
    }
    
    func navigateBackward() {
        navigationInstance?.goBack()
        stateCache["wentBack"] = true
    }
    
    func navigateForward() {
        navigationInstance?.goForward()
        stateCache["wentForward"] = true
    }
    
    func refreshContent() {
        navigationInstance?.reload()
        progressTracker = 0.0
    }
    
    func loadResourceLocation(_ url: URL) {
        let request = URLRequest(url: url)
        navigationInstance?.load(request)
        stateCache["loadedURL"] = url.absoluteString
    }
}

struct BoltRefreshablePortalRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: BoltPortalViewModel
    let initialURL: URL
    
    func makeCoordinator() -> BoltPortalCoordinator {
        return BoltPortalCoordinator(parent: BoltPortalRepresentable(viewModel: viewModel, initialURL: initialURL))
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let instance = WKWebView(frame: .zero, configuration: configuration)
        
        instance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        instance.scrollView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        instance.isOpaque = false
        
        instance.navigationDelegate = context.coordinator
        instance.uiDelegate = context.coordinator
        
        instance.allowsBackForwardNavigationGestures = true
        
        let modernUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
        instance.customUserAgent = modernUserAgent
        
        viewModel.setupInstance(with: instance)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        refreshControl.addTarget(context.coordinator, action: #selector(BoltPortalCoordinator.processRefreshAction(_:)), for: .valueChanged)
        instance.scrollView.refreshControl = refreshControl
        instance.scrollView.bounces = true
        
        context.coordinator.refreshControl = refreshControl
        context.coordinator.primaryInstance = instance
        
        FluxCookieStorageManager.shared.restoreCookieData(into: instance) {
            let request = URLRequest(url: self.initialURL)
            instance.load(request)
        }
        
        return instance
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

