//
//  SettingsViewModel.swift
//  ElectionDrop
//
//  Created by Daniel Heppner on 10/17/24.
//

import Foundation
import ElectionsGQL

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var elections = [ElectionsQuery.Data.AllElections.Node]()
    
    init() {
        Network.shared.apollo.fetch(query: ElectionsQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                if let nodes = graphQLResult.data?.allElections?.nodes {
                    self.elections = nodes.compactMap({ $0 })
                }
            case .failure(let error):
                // FIXME: Add error display
                print(error)
            }
        }
    }
}
