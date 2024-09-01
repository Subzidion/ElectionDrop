// MARK: - View

// ElectionListView.swift
import SwiftUI

struct ElectionListView: View {
    let elections: Set<Election>
    @State private var searchText = ""
    @State private var expandedSections: Set<String> = []
    @AppStorage("showPCOs") private var showPCOs = false
    @AppStorage("showKingCountyOnly") private var showKingCountyOnly = true
    
    private var districtsOutsideKingCounty: Set<String> = ["Federal", "State of Washington", "Congressional District No. 1",
                                                           "Congressional District No. 8", "Legislative District No. 1", "Legislative District No. 12",
                                                           "Legislative District No. 31", "Legislative District No. 32", "State Supreme Court",
                                                           "Valley Regional Fire Authority"]
    
    private let topLevelGroupings: Set<String> = ["State", "City", "Federal", "Special Purpose District"]
    
    init(elections: Set<Election>) {
        self.elections = elections
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                List {
                    ForEach(filteredElectionsTree.keys.sorted(), id: \.self) { topLevelGrouping in
                        if let groupData = filteredElectionsTree[topLevelGrouping], !groupData.isEmpty {
                            Section(header: Text(topLevelGrouping)) {
                                Group {
                                    electionsGroup(topLevelGrouping: topLevelGrouping, groupData: groupData)
                                }
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
    
    // Here be dragons, courtesy of Claude.
    private func electionsGroup(topLevelGrouping: String, groupData: [String: [String: [Election]]]) -> some View {
        ForEach(groupData.keys.sorted(), id: \.self) { subGrouping in
            if let subGroupData = groupData[subGrouping], !subGroupData.isEmpty {
                if topLevelGrouping == "State" && subGrouping == "State Legislature" {
                    DisclosureGroup(
                        isExpanded: expandedBinding(for: "\(topLevelGrouping)-\(subGrouping)"),
                        content: {
                            ForEach(subGroupData.keys.sorted(by: { key1, key2 in
                                // Get the first election from each group to compare districtSortKey
                                let firstElection1 = subGroupData[key1]?.first
                                let firstElection2 = subGroupData[key2]?.first
                                return firstElection1?.districtSortKey ?? 99999 < firstElection2?.districtSortKey ?? 99999
                            }), id: \.self) { districtName in
                                if let elections = subGroupData[districtName], !elections.isEmpty {
                                    DisclosureGroup(
                                        isExpanded: expandedBinding(for: "\(topLevelGrouping)-\(subGrouping)-\(districtName)"),
                                        content: {
                                            ForEach(elections.sorted(by: { $0.districtSortKey < $1.districtSortKey }), id: \.id) { election in
                                                ElectionRow(election: election)
                                            }
                                        },
                                        label: { Text(districtName) }
                                    )
                                }
                            }
                        },
                        label: { Text(subGrouping) }
                    )
                } else if topLevelGrouping == "State" {
                    DisclosureGroup(
                        isExpanded: expandedBinding(for: "\(topLevelGrouping)-\(subGrouping)"),
                        content: {
                            ForEach(subGroupData.keys.sorted(), id: \.self) { ballotTitle in
                                if let elections = subGroupData[ballotTitle], !elections.isEmpty {
                                    if elections.count == 1 {
                                        ElectionRow(election: elections[0])
                                    } else {
                                        DisclosureGroup(
                                            isExpanded: expandedBinding(for: "\(topLevelGrouping)-\(subGrouping)-\(ballotTitle)"),
                                            content: {
                                                ForEach(elections.sorted(by: { $0.districtSortKey < $1.districtSortKey }), id: \.id) { election in
                                                    ElectionRow(election: election)
                                                }
                                            },
                                            label: { Text(ballotTitle) }
                                        )
                                    }
                                }
                            }
                        },
                        label: { Text(subGrouping) }
                    )
                } else {
                    // This handles City, Federal, and Special Purpose District
                    ForEach(subGroupData.keys.sorted(), id: \.self) { groupKey in
                        if let elections = subGroupData[groupKey], !elections.isEmpty {
                            DisclosureGroup(
                                isExpanded: expandedBinding(for: "\(subGrouping)-\(groupKey)"),
                                content: {
                                    ForEach(elections.sorted(by: { $0.districtSortKey < $1.districtSortKey }), id: \.id) { election in
                                        ElectionRow(election: election)
                                    }
                                },
                                label: { Text(groupKey) }
                            )
                        }
                    }
                }
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
    
    /**
     Create the Elections Tree structure for the ElectionListView, applying the desired filters.
     We lump in PCOs and Supreme Courts with State Elections because that's logical to me, even though the CSV data does not.
     */
    private var filteredElectionsTree: [String: [String: [String: [Election]]]] {
        let filteredElections = elections.filter { election in
            let kingCountyCondition = !showKingCountyOnly || !districtsOutsideKingCounty.contains(election.districtName)
            let pcoCondition = showPCOs || election.districtType != "Precinct Committee Officer"
            let searchCondition = searchText.isEmpty || election.matchesSearch(searchText)
            return kingCountyCondition && pcoCondition && searchCondition
        }
        
        return Dictionary(grouping: filteredElections, by: \.treeDistrictType)
            .mapValues(groupElections)
        
    }
    
    private func groupElections(_ elections: [Election]) -> [String: [String: [Election]]] {
        if elections.first?.treeDistrictType == "State" {
            // State has Sub-lists for individual Elections
            // State Executive, State Legislature, and State Supreme Court
            // We need to generate those.
            return groupStateElections(elections)
        } else if elections.first?.treeDistrictType == "City" || elections.first?.treeDistrictType == "Special Purpose District" {
            // For Cities and Special Purpose Districts, it makes more sense to group by District Name (the City or District) than by the Ballot Title.
            return ["": Dictionary(grouping: elections) { $0.districtName }]
        } else if topLevelGroupings.contains(elections.first?.districtType ?? "") {
            // If the topLevelGroupings collection contains the districtType of the first election in the elections array, or an empty string if there are no elections.
            return ["": Dictionary(grouping: elections) { $0.ballotTitle }]
        } else {
            return ["": ["": elections]]
        }
    }
    
    /**
     Group the State Elections into either State Legislature, State Executive, State Supreme Court, or Precinct Committee Officers.
     State Elections are currently the only one that have a desired sub-tree structure, so we create it here.
     */
    private func groupStateElections(_ elections: [Election]) -> [String: [String: [Election]]] {
        var stateSubGroups: [String: [String: [Election]]] = [
            "State Legislature": [:],
            "State Executive": [:],
            "State Supreme Court": [:]
        ]
        
        if showPCOs {
            stateSubGroups["Precinct Committee Officer"] = [:]
        }
        
        for election in elections {
            if election.districtType == "Precinct Committee Officer" && showPCOs {
                stateSubGroups["Precinct Committee Officer"]?[election.ballotTitle, default: []].append(election)
            } else if election.districtType == "State Supreme Court" {
                stateSubGroups["State Supreme Court"]?[election.ballotTitle, default: []].append(election)
            } else if election.ballotTitle.contains("Representative") || election.ballotTitle.contains("State Senator") {
                stateSubGroups["State Legislature"]?[election.districtName, default: []].append(election)
            } else {
                stateSubGroups["State Executive"]?[election.ballotTitle, default: []].append(election)
            }
        }
        
        return stateSubGroups.filter { !$0.value.isEmpty }
    }
    
    struct ElectionRow: View {
        let election: Election
        
        var body: some View {
            NavigationLink(value: election) {
                VStack(alignment: .leading) {
                    if election.ballotTitle == "United States Representative" {
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
