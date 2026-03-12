import Foundation
import Combine

class EdgeTipDetailSparkViewModel: ObservableObject {
    @Published var currentTip: VortexFuelTipNexusModel?
    
    private let dataRepository: ApexFuelTipRepositoryProtocol
    
    init(dataRepository: ApexFuelTipRepositoryProtocol, tipIdentifier: UUID) {
        self.dataRepository = dataRepository
        self.currentTip = dataRepository.fetchTipByIdentifier(identifier: tipIdentifier)
    }
    
    func toggleFavoriteStatus() {
        guard var tip = currentTip else { return }
        dataRepository.switchFavoriteStatus(tip: tip)
        tip.favoriteStatus.toggle()
        currentTip = tip
    }
}



