// MARK: - View

import SwiftUI

struct ContestListView: View {
    let contests: Set<Contest>
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
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(ContestGroup.allCases, id: \.self) { group in
                            if let groupData = filteredContestTree[group], !groupData.isEmpty {
                                Section {
                                    contestsGroup(group: group, groupData: groupData)
                                } header: {
                                    Text(group.rawValue)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(UIColor.systemBackground))
                                }
                            }
                        }
                    }
                    .animation(.easeInOut, value: expandedSections)
                }
            }
            .navigationTitle("August 2024 Primary")
            .navigationDestination(for: Contest.self) { contest in
                ContestView(contest: contest)
            }
        }
    }
    
    private func contestsGroup(group: ContestGroup, groupData: [String: [String: [Contest]]]) -> some View {
        ForEach(groupData.keys.sorted(), id: \.self) { subGrouping in
            if let subGroupData = groupData[subGrouping], !subGroupData.isEmpty {
                group.view(for: subGrouping, subGroupData: subGroupData, expandedBinding: self.expandedBinding, isSearching: !searchText.isEmpty)
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
    
    private var filteredContestTree: [ContestGroup: [String: [String: [Contest]]]] {
        let filteredContests = contests.filter { contest in
            let kingCountyCondition = !showKingCountyOnly || !districtsOutsideKingCounty.contains(contest.districtName)
            let pcoCondition = showPCOs || contest.districtType != "Precinct Committee Officer"
            let searchCondition = searchText.isEmpty || contest.matchesSearch(searchText)
            return kingCountyCondition && pcoCondition && searchCondition
        }
        
        return Dictionary(grouping: filteredContests, by: \.group)
            .mapValues { ContestGroup.groupContests($0, showPCOs: showPCOs) }
    }
}

struct ContestRow: View {
    let contest: Contest
    
    var body: some View {
        NavigationLink(value: contest) {
            VStack(alignment: .leading, spacing: 4) {
                if contest.ballotTitle == "United States Representative" || contest.ballotTitle.starts(with: "Precinct Committee Officer") {
                    Text(contest.districtName)
                } else {
                    Text(contest.ballotTitle)
                }
            }
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search contests", text: $text)
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

struct CustomDisclosureGroup<Label: View, Content: View>: View {
    @Binding var isExpanded: Bool
    let content: Content
    let label: Label
    
    init(isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self._isExpanded = isExpanded
        self.content = content()
        self.label = label()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    label
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.right.circle.fill": "chevron.right.circle")
                        .foregroundColor(.accentColor)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            
            if isExpanded {
                content
                    .padding(.leading, 16)
            }
        }
    }
}

extension Contest {
    func matchesSearch(_ searchText: String) -> Bool {
        ballotTitle.localizedCaseInsensitiveContains(searchText) ||
        districtName.localizedCaseInsensitiveContains(searchText) ||
        updates.last?.results.contains(where: {
            $0.ballotResponse.localizedCaseInsensitiveContains(searchText)
        }) ?? false
    }
}

#Preview {
    let mockContests: Set<Contest> = [
        Contest(
            districtSortKey: 350,
            districtName: "Congressional District No. 9",
            districtType: "Federal",
            treeDistrictType: "Federal",
            ballotTitle: "United States Representative",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Joe Federale", voteCount: 37571, votePercent: 85.36),
                        ContestResult(ballotResponse: "Jolie Feds", voteCount: 6398, votePercent: 14.54)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 60,
            districtName: "State Executive",
            districtType: "State Executive",
            treeDistrictType: "State",
            ballotTitle: "Governor",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Bob Ferguson", voteCount: 340334, votePercent: 61.30),
                        ContestResult(ballotResponse: "Dave Reichert", voteCount: 109374, votePercent: 19.70),
                        ContestResult(ballotResponse: "Mark Mullet", voteCount: 45323, votePercent: 8.16)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 70,
            districtName: "State",
            districtType: "State Supreme Court",
            treeDistrictType: "State",
            ballotTitle: "Justice Position No. 2",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Sal Mungia", voteCount: 301394, votePercent: 59.37),
                        ContestResult(ballotResponse: "Dave Larson", voteCount: 135346, votePercent: 26.66)
                    ]
                )
            ]
        ),
        
        Contest(
            districtSortKey: 350,
            districtName: "Legislative District No. 34",
            districtType: "State Legislative",
            treeDistrictType: "State",
            ballotTitle: "Representative Position No. 2",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Joe Fitzgibbon", voteCount: 37571, votePercent: 85.36),
                        ContestResult(ballotResponse: "Jolie Lansdowne", voteCount: 6398, votePercent: 14.54)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 340,
            districtName: "Legislative District No. 34",
            districtType: "State Legislative",
            treeDistrictType: "State",
            ballotTitle: "Representative Position No. 1",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Joey Fitzgibbony", voteCount: 37571, votePercent: 85.36),
                        ContestResult(ballotResponse: "Jolieee Lansdowneee", voteCount: 6398, votePercent: 14.54)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 390,
            districtName: "Legislative District No. 36",
            districtType: "State Legislative",
            treeDistrictType: "State",
            ballotTitle: "Representative Position No. 2",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Joe Fitzgibbon", voteCount: 37571, votePercent: 85.36),
                        ContestResult(ballotResponse: "Jolie Lansdowne", voteCount: 6398, votePercent: 14.54)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 385,
            districtName: "Legislative District No. 36",
            districtType: "State Legislative",
            treeDistrictType: "State",
            ballotTitle: "Representative Position No. 1",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Joey Fitzgibbony", voteCount: 37571, votePercent: 85.36),
                        ContestResult(ballotResponse: "Jolieee Lansdowneee", voteCount: 6398, votePercent: 14.54)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 570,
            districtName: "City of Seattle",
            districtType: "City",
            treeDistrictType: "City",
            ballotTitle: "Council Position No. 8",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Alexis Mercedes Rinck", voteCount: 99394, votePercent: 50.18),
                        ContestResult(ballotResponse: "Tanya Woo", voteCount: 76008, votePercent: 38.38)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 580,
            districtName: "City of Seattle",
            districtType: "City",
            treeDistrictType: "City",
            ballotTitle: "Council Position No. 9",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Carl Hiltbrunner", voteCount: 99394, votePercent: 50.18),
                        ContestResult(ballotResponse: "Leonord Jerome", voteCount: 76008, votePercent: 38.38)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 10,
            districtName: "Federal",
            districtType: "Federal",
            treeDistrictType: "Federal",
            ballotTitle: "United States Senator",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Maria Cantwell", voteCount: 409728, votePercent: 74.53),
                        ContestResult(ballotResponse: "Dr Raul Garcia", voteCount: 72234, votePercent: 13.14)
                    ]
                )
            ]
        ),
        Contest(
            districtSortKey: 600,
            districtName: "South King Fire",
            districtType: "Special Purpose District",
            treeDistrictType: "Special Purpose District",
            ballotTitle: "Proposition No. 1",
            updates: [
                ContestResultsUpdate(
                    updateTime: Date(),
                    updateCount: 10,
                    results: [
                        ContestResult(ballotResponse: "Yes", voteCount: 19094, votePercent: 65.28),
                        ContestResult(ballotResponse: "No", voteCount: 10155, votePercent: 34.72)
                    ]
                )
            ]
        )
    ]
    
    return ContestListView(contests: mockContests)
}
