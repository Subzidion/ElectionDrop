// MARK: - View

// ElectionListView.swift
import SwiftUI

struct ElectionListView: View {
    let elections: Set<Election>
    @State private var searchText = ""
    @State private var expandedSections: Set<String> = []
    @AppStorage("showPCOs") private var showPCOs = false
    @AppStorage("showKingCountyOnly") private var showKingCountyOnly = true
    
    private let districtsOutsideKingCounty: Set<String> = [
        "Federal", "State of Washington", "Congressional District No. 1",
        "Congressional District No. 8", "Legislative District No. 1", "Legislative District No. 12",
        "Legislative District No. 31", "Legislative District No. 32", "State Supreme Court",
        "Valley Regional Fire Authority"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                List {
                    ForEach(ElectionGroup.allCases, id: \.self) { group in
                        if let groupData = filteredElectionsTree[group], !groupData.isEmpty {
                            Section(header: Text(group.rawValue)) {
                                electionsGroup(group: group, groupData: groupData)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Elections")
            .navigationDestination(for: Election.self) { election in
                ElectionView(election: election)
            }
        }
    }
    
    private func electionsGroup(group: ElectionGroup, groupData: [String: [String: [Election]]]) -> some View {
        ForEach(groupData.keys.sorted(), id: \.self) { subGrouping in
            if let subGroupData = groupData[subGrouping], !subGroupData.isEmpty {
                group.view(for: subGrouping, subGroupData: subGroupData, expandedBinding: self.expandedBinding)
            }
        }
    }
    
    private func expandedBinding(for key: String) -> Binding<Bool> {
        Binding(
            get: { self.searchText.isEmpty ? self.expandedSections.contains(key) : true },
            set: { newValue in
                if newValue {
                    self.expandedSections.insert(key)
                } else {
                    self.expandedSections.remove(key)
                }
            }
        )
    }
    
    private var filteredElectionsTree: [ElectionGroup: [String: [String: [Election]]]] {
        let filteredElections = elections.filter { election in
            let kingCountyCondition = !showKingCountyOnly || !districtsOutsideKingCounty.contains(election.districtName)
            let pcoCondition = showPCOs || election.districtType != "Precinct Committee Officer"
            let searchCondition = searchText.isEmpty || election.matchesSearch(searchText)
            return kingCountyCondition && pcoCondition && searchCondition
        }
        
        return Dictionary(grouping: filteredElections, by: \.group)
            .mapValues { ElectionGroup.groupElections($0, showPCOs: showPCOs) }
    }
}

struct ElectionRow: View {
    let election: Election
    
    var body: some View {
        NavigationLink(value: election) {
            VStack(alignment: .leading) {
                if election.ballotTitle == "United States Representative" || election.ballotTitle.starts(with: "Precinct Committee Officer") {
                    Text(election.districtName)
                        .font(.headline)
                } else {
                    Text(election.ballotTitle)
                        .font(.headline)
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search elections", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

extension Election {
    func matchesSearch(_ searchText: String) -> Bool {
        ballotTitle.localizedCaseInsensitiveContains(searchText) ||
        districtName.localizedCaseInsensitiveContains(searchText) ||
        updates.last?.results.contains(where: {
            $0.ballotResponse.localizedCaseInsensitiveContains(searchText)
        }) ?? false
    }
}
