// MARK: - View

// ElectionListView.swift
import SwiftUI

struct ElectionListView: View {
    let elections: Set<Election>
    @State private var searchText = ""
    
    var filteredElections: [Election] {
        let nonPCOElections = elections.filter { !$0.ballotTitle.starts(with: "Precinct Committee Officer") }
        
        if searchText.isEmpty {
            return Array(nonPCOElections).sorted(by: { $0.ballotTitle < $1.ballotTitle })
        } else {
            return nonPCOElections.filter { election in
                election.ballotTitle.localizedCaseInsensitiveContains(searchText) ||
                election.districtName.localizedCaseInsensitiveContains(searchText) ||
                election.updates.last?.results.contains(where: {
                    $0.ballotResponse.localizedCaseInsensitiveContains(searchText)
                }) ?? false
            }.sorted(by: { $0.ballotTitle < $1.ballotTitle })
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredElections, id: \.id) { election in
                NavigationLink(destination: ElectionView(election: election)) {
                        VStack(alignment: .leading) {
                            Text(election.districtName)
                                .font(.headline)
                            Text(election.ballotTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
            }
            .navigationTitle("Elections")
            .searchable(text: $searchText, prompt: "Search elections")
        }
    }
}
