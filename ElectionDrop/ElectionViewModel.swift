// MARK: - ViewModel

// ElectionViewModel.swift
import Foundation
import Combine

@MainActor
class ElectionViewModel: ObservableObject {
    @Published private(set) var elections: Set<Election> = []
    @Published private(set) var isLoading = true
    
    private let electionService: ElectionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(electionService: ElectionServiceProtocol = ElectionService()) {
        self.electionService = electionService
        setupBindings()
    }
    
    private func setupBindings() {
        electionService.electionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] elections in
                self?.elections = elections
                if !elections.isEmpty {
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
        
        electionService.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
    }
   
    func loadElectionData() async {
        isLoading = true
        await electionService.fetchElectionUpdate()
    }
}
