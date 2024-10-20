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
    @Published private(set) var isLoading = true
    
    @AppStorage("selectedElectionId") private var selectedElectionId: String?

    func loadElectionData() async {
        isLoading = true
        if (selectedElectionId != nil) {
            let electionId = selectedElectionId!
            Network.shared.apollo.fetch(query: ContestsQuery(electionId: electionId)) { result in
                switch result {
                case .success(let gqlData):
                    let gqlContests = gqlData.data?.allContests?.nodes.compactMap({ $0 }) ?? []
                    let gqlUpdates = gqlData.data?.allUpdates?.nodes.compactMap({$0}) ?? []
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
                switch result {
                case .success(let gqlData):
                    if let election = gqlData.data?.allElections?.nodes.first {
                        // Note: these are safe to cast because the shape of the GraphQL query is the same in both queries!
                        let gqlUpdates = election?.updatesByElectionId.nodes.compactMap(( {$0} )) as! [ContestsQuery.Data.AllUpdates.Node]
                        let gqlContests = election?.contestsByElectionId.nodes.compactMap(({$0})) as! [ContestsQuery.Data.AllContests.Node]
                        self.contests = gqlContests.map({ Contest.fromGqlResponse(from: $0) })
                        self.updates = gqlUpdates.map({ ElectionResultsUpdate.fromGqlResponse(from: $0) })
                    }
                    
                case .failure(let error):
                    // FIXME: Handle error forreal
                    print(error)
                }
            }
        }
    }
}
