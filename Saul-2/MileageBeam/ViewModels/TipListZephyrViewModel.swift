import Foundation
import Combine

class ZenithTipListCipherViewModel: ObservableObject {
    @Published var tipsCollection: [VortexFuelTipNexusModel] = []
    @Published var activeFilters: QuantumTipFilterPrism = QuantumTipFilterPrism()
    @Published var currentVehicleSelection: String = "Car"
    @Published var currentScenarioSelection: String? = nil
    @Published var searchQueryText: String = ""
    @Published var favoritesOnlyToggle: Bool = false
    
    private let dataRepository: ApexFuelTipRepositoryProtocol
    private var subscriptionBag = Set<AnyCancellable>()
    
    init(dataRepository: ApexFuelTipRepositoryProtocol) {
        self.dataRepository = dataRepository
        configureBindings()
        loadTipsData()
    }
    
    private func configureBindings() {
        Publishers.CombineLatest4(
            $currentVehicleSelection,
            $currentScenarioSelection,
            $searchQueryText,
            $favoritesOnlyToggle
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] _, _, _, _ in
            self?.loadTipsData()
        }
        .store(in: &subscriptionBag)
    }
    
    func loadTipsData() {
        var filterConfig = QuantumTipFilterPrism()
        filterConfig.transportCategory = currentVehicleSelection
        filterConfig.querySearchText = searchQueryText.isEmpty ? nil : searchQueryText
        filterConfig.favoriteOnlyFlag = favoritesOnlyToggle ? true : nil
        
        var filteredTips = dataRepository.retrieveTipsWithFilter(filter: filterConfig)
        
        if let selectedScenario = currentScenarioSelection {
            filteredTips = filteredTips.filter { $0.contextScenario == selectedScenario }
        }
        
        tipsCollection = filteredTips
    }
    
    func switchScenarioSelection(_ scenario: String) {
        if currentScenarioSelection == scenario {
            currentScenarioSelection = nil
        } else {
            currentScenarioSelection = scenario
        }
        loadTipsData()
    }
}



