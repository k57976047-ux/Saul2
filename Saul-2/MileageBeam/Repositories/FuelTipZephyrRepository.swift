import Foundation
import CoreData

class BoltFuelTipRepository: ApexFuelTipRepositoryProtocol {
    private let dataController = MatrixPersistenceController.shared
    private var cachedTips: [VortexFuelTipNexusModel] = []
    
    init() {
        initializeDataLoad()
    }
    
    private func initializeDataLoad() {
        let context = dataController.container.viewContext
        let request: NSFetchRequest<FuelTipZephyrEntity> = FuelTipZephyrEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            if entities.isEmpty {
                populateInitialData()
            } else {
                cachedTips = entities.map { convertEntityToModel($0) }
            }
        } catch {
            populateInitialData()
        }
    }
    
    private func populateInitialData() {
        let initialData = StreamInitialFuelTipsData.retrieveTipsData()
        let context = dataController.container.viewContext
        
        for tip in initialData {
            let entity = FuelTipZephyrEntity(context: context)
            entity.id = tip.id.uuidString
            entity.title = tip.headerTitle
            entity.vehicleType = tip.transportCategory
            entity.scenario = tip.contextScenario
            entity.descriptionText = tip.contentDescription
            entity.isFavorite = tip.favoriteStatus
        }
        
        dataController.saveZephyrContext()
        cachedTips = initialData
    }
    
    func retrieveAllTipsMatrix() -> [VortexFuelTipNexusModel] {
        let context = dataController.container.viewContext
        let request: NSFetchRequest<FuelTipZephyrEntity> = FuelTipZephyrEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.map { convertEntityToModel($0) }
        } catch {
            return cachedTips
        }
    }
    
    func retrieveTipsWithFilter(filter: QuantumTipFilterPrism) -> [VortexFuelTipNexusModel] {
        let context = dataController.container.viewContext
        let request: NSFetchRequest<FuelTipZephyrEntity> = FuelTipZephyrEntity.fetchRequest()
        var filterPredicates: [NSPredicate] = []
        
        if let transportCategory = filter.transportCategory {
            filterPredicates.append(NSPredicate(format: "vehicleType == %@", transportCategory))
        }
        
        if let contextScenario = filter.contextScenario {
            filterPredicates.append(NSPredicate(format: "scenario == %@", contextScenario))
        }
        
        if let favoriteOnlyFlag = filter.favoriteOnlyFlag, favoriteOnlyFlag {
            filterPredicates.append(NSPredicate(format: "isFavorite == YES"))
        }
        
        if !filterPredicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates)
        }
        
        do {
            let entities = try context.fetch(request)
            var filteredTips = entities.map { convertEntityToModel($0) }
            
            if let searchQuery = filter.querySearchText, !searchQuery.isEmpty {
                filteredTips = filteredTips.filter { tip in
                    tip.headerTitle.localizedCaseInsensitiveContains(searchQuery) ||
                    tip.contentDescription.localizedCaseInsensitiveContains(searchQuery)
                }
            }
            
            return filteredTips
        } catch {
            var filteredTips = cachedTips
            
            if let transportCategory = filter.transportCategory {
                filteredTips = filteredTips.filter { $0.transportCategory == transportCategory }
            }
            
            if let contextScenario = filter.contextScenario {
                filteredTips = filteredTips.filter { $0.contextScenario == contextScenario }
            }
            
            if let favoriteOnlyFlag = filter.favoriteOnlyFlag, favoriteOnlyFlag {
                filteredTips = filteredTips.filter { $0.favoriteStatus }
            }
            
            if let searchQuery = filter.querySearchText, !searchQuery.isEmpty {
                filteredTips = filteredTips.filter { tip in
                    tip.headerTitle.localizedCaseInsensitiveContains(searchQuery) ||
                    tip.contentDescription.localizedCaseInsensitiveContains(searchQuery)
                }
            }
            
            return filteredTips
        }
    }
    
    func fetchTipByIdentifier(identifier: UUID) -> VortexFuelTipNexusModel? {
        let context = dataController.container.viewContext
        let request: NSFetchRequest<FuelTipZephyrEntity> = FuelTipZephyrEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", identifier.uuidString)
        
        do {
            let entities = try context.fetch(request)
            return entities.first.map { convertEntityToModel($0) }
        } catch {
            return cachedTips.first(where: { $0.id == identifier })
        }
    }
    
    func switchFavoriteStatus(tip: VortexFuelTipNexusModel) {
        let context = dataController.container.viewContext
        let request: NSFetchRequest<FuelTipZephyrEntity> = FuelTipZephyrEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tip.id.uuidString)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.isFavorite.toggle()
                dataController.saveZephyrContext()
                
                if let index = cachedTips.firstIndex(where: { $0.id == tip.id }) {
                    cachedTips[index].favoriteStatus.toggle()
                }
            }
        } catch {
        }
    }
    
    private func convertEntityToModel(_ entity: FuelTipZephyrEntity) -> VortexFuelTipNexusModel {
        let uuid = UUID(uuidString: entity.id ?? "") ?? UUID()
        return VortexFuelTipNexusModel(
            identifier: uuid,
            headerTitle: entity.title ?? "",
            transportCategory: entity.vehicleType ?? "",
            contextScenario: entity.scenario ?? "",
            contentDescription: entity.descriptionText ?? "",
            favoriteStatus: entity.isFavorite
        )
    }
}

