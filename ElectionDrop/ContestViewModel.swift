// MARK: - ViewModel

// ElectionViewModel.swift
import Foundation

@MainActor
class ContestViewModel: ObservableObject {
    @Published private(set) var contests: Set<Contest> = []
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
        contests = await electionService.getElections()
        isLoading = false
    }
}
