// MARK: - ViewModel

// ElectionViewModel.swift

import Foundation

@MainActor
class ElectionViewModel: ObservableObject {
    @Published private(set) var elections: Set<Election> = []
    @Published private(set) var isLoading = true
    
    private let electionService: ElectionServiceProtocol
    
    init(electionService: ElectionServiceProtocol = ElectionService()) {
        self.electionService = electionService
    }
    
    func loadElectionData() async {
        isLoading = true
        await updateElections()
    }
    
    private func updateElections() async {
        await electionService.fetchElectionUpdate()
        elections = await electionService.getElections()
        isLoading = false
    }
}
