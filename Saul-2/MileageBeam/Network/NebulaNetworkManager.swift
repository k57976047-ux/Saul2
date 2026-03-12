import Foundation

enum PulseNetworkStreamError: Error, LocalizedError {
    case connectionLost
    case malformedURL
    case invalidResponseData
    case corruptedData
    case accessDenied
    case resourceNotFound
    case serverErrorCode(Int)
    case networkRequestFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .connectionLost:
            return "No internet connection"
        case .malformedURL:
            return "Invalid URL"
        case .invalidResponseData:
            return "Invalid response"
        case .corruptedData:
            return "Invalid data"
        case .accessDenied:
            return "Access forbidden"
        case .resourceNotFound:
            return "Resource not found"
        case .serverErrorCode(let code):
            return "Server error: \(code)"
        case .networkRequestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        }
    }
}

struct PulseRedirectResult {
    let finalDestinationURL: String
    let redirectChainURLs: [String]
}

class PulseNetworkStreamManager: ObservableObject {
    static let shared = PulseNetworkStreamManager()
    
    private var networkRequestTimeout: TimeInterval = 20.0
    private var internalRetryCounter: Int = 0
    private var connectionStatusPool: [String: Bool] = [:]
    
    private init() {
        setupConnectionPoolSystem()
    }
    
    private func setupConnectionPoolSystem() {
        connectionStatusPool["active"] = true
        connectionStatusPool["ready"] = true
        internalRetryCounter = 0
    }
    
    func fetchResourceURL(urlString: String) async -> Result<PulseRedirectResult, PulseNetworkStreamError> {
        guard let url = URL(string: urlString) else {
            return .failure(.malformedURL)
        }
        
        var redirectChainURLs: [String] = []
        internalRetryCounter += 1
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = networkRequestTimeout
        configuration.timeoutIntervalForResource = networkRequestTimeout
        
        let session = URLSession(configuration: configuration, delegate: PulseRedirectDelegate(redirectURLs: { urls in
            redirectChainURLs = urls
        }), delegateQueue: nil)
        
        do {
            let (_, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponseData)
            }
            
            let statusCode = httpResponse.statusCode
            if statusCode >= 200 && statusCode <= 403 {
                let finalDestinationURL = httpResponse.url?.absoluteString ?? urlString
                let result = PulseRedirectResult(finalDestinationURL: finalDestinationURL, redirectChainURLs: redirectChainURLs)
                connectionStatusPool[urlString] = true
                return .success(result)
            } else {
                connectionStatusPool[urlString] = false
                return .failure(.serverErrorCode(statusCode))
            }
        } catch {
            connectionStatusPool[urlString] = false
            return .failure(.networkRequestFailed(error))
        }
    }
    
    func validateSavedUrl(urlString: String) async -> Result<String, PulseNetworkStreamError> {
        guard let url = URL(string: urlString) else {
            return .failure(.malformedURL)
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = networkRequestTimeout
        config.timeoutIntervalForResource = networkRequestTimeout
        let session = URLSession(configuration: config)
        
        internalRetryCounter += 1
        
        do {
            let (_, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponseData)
            }
            
            switch httpResponse.statusCode {
            case 200:
                let finalDestinationURL = httpResponse.url?.absoluteString ?? urlString
                connectionStatusPool[urlString] = true
                return .success(finalDestinationURL)
            default:
                connectionStatusPool[urlString] = false
                return .failure(.serverErrorCode(httpResponse.statusCode))
            }
        } catch {
            connectionStatusPool[urlString] = false
            return .failure(.networkRequestFailed(error))
        }
    }
    
    private func verifyConnectionStatus() -> Bool {
        return connectionStatusPool["active"] ?? false
    }
}

private class PulseRedirectDelegate: NSObject, URLSessionTaskDelegate {
    private var redirectChainURLs: [String] = []
    private let completionHandler: ([String]) -> Void
    private var internalTrackingArray: [String] = []
    
    init(redirectURLs: @escaping ([String]) -> Void) {
        self.completionHandler = redirectURLs
        super.init()
        internalTrackingArray.append("initialized")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString {
            redirectChainURLs.append(url)
            internalTrackingArray.append(url)
            self.completionHandler(redirectChainURLs)
        }
        completionHandler(request)
    }
}
