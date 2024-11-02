// MARK: - ViewModel
import Foundation
import SwiftUI
import ElectionsGQL

enum JurisdictionType: String, Codable {
    case state = "State"
    case county = "County"
}

@MainActor
class DataModel: ObservableObject {
    @Published private(set) var contests: [Contest] = []
    @Published private(set) var updates: [ElectionResultsUpdate] = []
    @Published private(set) var isInitialLoading = true // New state for initial load
    @Published private(set) var isRefreshing = false // New state for refresh operations
    
    @AppStorage("selectedElectionId") private var selectedElectionId: String?
    @AppStorage("selectedElectionName") private var selectedElectionName: String?
    
    var currentElectionName: String {
        selectedElectionName ?? "Latest Election"
    }

    func loadElectionData() async {
        // If we have no data, show full screen loading
        if contests.isEmpty {
            isInitialLoading = true
        } else {
            // Otherwise, just show refresh indicator
            isRefreshing = true
        }
        
        if (selectedElectionId != nil) {
            let electionId = selectedElectionId!
            Network.shared.apollo.fetch(query: ContestsQuery(electionId: electionId)) { result in
                self.isInitialLoading = false
                self.isRefreshing = false
                switch result {
                case .success(let gqlData):
                    let gqlContests = gqlData.data?.allContests?.nodes.compactMap { $0?.fragments.contestData } ?? []
                    let gqlUpdates = gqlData.data?.allUpdates?.nodes.compactMap {$0?.fragments.updateData} ?? []
                    self.contests = gqlContests.map({ Contest.fromGqlResponse(from: $0) })
                    self.updates = gqlUpdates.map({ ElectionResultsUpdate.fromGqlResponse(from: $0) })
                case .failure(let error):
                    // FIXME: Handle error forreal
                    print(error)
                }
            }
        } else {
            // no election ID
            Network.shared.apollo.fetch(query: FirstElectionContestsQuery()) { result in
                self.isInitialLoading = false
                self.isRefreshing = false
                switch result {
                case .success(let gqlData):
                    if let election = gqlData.data?.allElections?.nodes.first {
                        // Note: these are safe to cast because the shape of the GraphQL query is the same in both queries!
                        let gqlUpdates = election?.updatesByElectionId.nodes.compactMap {$0?.fragments.updateData} ?? []
                        let gqlContests = election?.contestsByElectionId.nodes.compactMap { $0?.fragments.contestData } ?? []
                        self.contests = gqlContests.map({ Contest.fromGqlResponse(from: $0) })
                        self.updates = gqlUpdates.map({ ElectionResultsUpdate.fromGqlResponse(from: $0) })
                        // Store the name of the latest election
                        self.selectedElectionName = election?.name
                    }
                    
                case .failure(let error):
                    // FIXME: Handle error forreal
                    print(error)
                }
            }
        }
    }
}
