import Foundation

struct VortexFuelTipNexusModel: Identifiable, Codable {
    let id: UUID 
    var headerTitle: String
    var transportCategory: String
    var contextScenario: String
    var contentDescription: String
    var favoriteStatus: Bool
    
    init(identifier: UUID = UUID(), headerTitle: String, transportCategory: String, contextScenario: String, contentDescription: String, favoriteStatus: Bool = false) {
        self.id = identifier
        self.headerTitle = headerTitle
        self.transportCategory = transportCategory
        self.contextScenario = contextScenario
        self.contentDescription = contentDescription
        self.favoriteStatus = favoriteStatus
    }
}

struct QuantumTipFilterPrism {
    var transportCategory: String?
    var contextScenario: String?
    var querySearchText: String?
    var favoriteOnlyFlag: Bool?
}



