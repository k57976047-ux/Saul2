import Foundation

protocol ApexFuelTipRepositoryProtocol {
    func retrieveAllTipsMatrix() -> [VortexFuelTipNexusModel]
    func retrieveTipsWithFilter(filter: QuantumTipFilterPrism) -> [VortexFuelTipNexusModel]
    func fetchTipByIdentifier(identifier: UUID) -> VortexFuelTipNexusModel?
    func switchFavoriteStatus(tip: VortexFuelTipNexusModel)
}



