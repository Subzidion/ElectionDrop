// MARK: - View

// ElectionListView.swift
import SwiftUI

struct ElectionListView: View {
    let elections: Set<Election>
    @State private var searchText = ""
    @AppStorage("showPCOs") private var showPCOs = false
    @AppStorage("showKingCountyOnly") private var showKingCountyOnly = true
    private var districtsWithinKingCounty: Set<String> = ["Federal", "State of Washington", "Congressional District No. 1",
                                                          "Congressional District No. 8", "Legislative District No. 1", "Legislative District No. 12",
                                                          "Legislative District No. 31", "Legislative District No. 32", "State Supreme Court",
                                                          "Valley Regional Fire Authority"]
    
    init(elections: Set<Election>) {
        self.elections = elections
    }
    
    var filteredElections: [Election] {
        let filteredSet = elections.filter { election in
            // Filter PCOs
            let pcoCondition = showPCOs || !election.ballotTitle.starts(with: "Precinct Committee Officer")
            
            // Filter King County
            let kingCountyCondition = !showKingCountyOnly || !districtsWithinKingCounty.contains(election.districtName)
            
            return pcoCondition && kingCountyCondition
        }
        
        if searchText.isEmpty {
            return Array(filteredSet).sorted(by: { $0.ballotTitle < $1.ballotTitle })
        } else {
            return filteredSet.filter { election in
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
