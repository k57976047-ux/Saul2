import Foundation
import Combine

class FluxStatisticsVectorViewModel: ObservableObject {
    @Published var vehicleDistributionMap: [String: Int] = [:]
    @Published var scenarioDistributionMap: [String: Int] = [:]
    @Published var favoriteScenarioMap: [String: Int] = [:]
    
    private let dataSource: ApexFuelTipRepositoryProtocol
    
    init(dataSource: ApexFuelTipRepositoryProtocol) {
        self.dataSource = dataSource
        refreshStatisticsData()
    }
    
    func refreshStatisticsData() {
        let allTipsData = dataSource.retrieveAllTipsMatrix()
        vehicleDistributionMap = Dictionary(grouping: allTipsData, by: { $0.transportCategory }).mapValues { $0.count }
        scenarioDistributionMap = Dictionary(grouping: allTipsData, by: { $0.contextScenario }).mapValues { $0.count }
        
        let favoriteTipsData = allTipsData.filter { $0.favoriteStatus }
        favoriteScenarioMap = Dictionary(grouping: favoriteTipsData, by: { $0.contextScenario }).mapValues { $0.count }
    }
}



