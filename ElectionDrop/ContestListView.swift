// MARK: - View

import SwiftUI

struct ContestListView: View {
    let contests: [Contest]
    @State private var searchText = ""
    @State private var expandedSections: Set<String> = []
    @AppStorage("showPCOs") private var showPCOs = false
    
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
        let orderedContests = self.contests.sorted {
            return $0.ballotTitle.localizedStandardCompare($1.ballotTitle) == .orderedAscending
        }

        let filteredContests = orderedContests.filter { contest in
            let pcoCondition = showPCOs || contest.isPCO
            let searchCondition = searchText.isEmpty || contest.matchesSearch(searchText)
            return pcoCondition && searchCondition
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
        districtName.localizedCaseInsensitiveContains(searchText)
    }
}


#Preview {
    let mockContests: [Contest] = [
        Contest(
            districtName: "Congressional District No. 9",
            ballotTitle: "United States Representative",
            jurisdictionTypes: [.county, .state],
            id: "contest1"
        ),
        Contest(
            districtName: "State Executive",
            ballotTitle: "Governor",
            jurisdictionTypes: [.state],
            id: "contest2"
        ),
        Contest(
            districtName: "State",
            ballotTitle: "Justice Position No. 2",
            jurisdictionTypes: [.state],
            id: "contest3"
        ),
        Contest(
            districtName: "Legislative District No. 34",
            ballotTitle: "Representative Position No. 2",
            jurisdictionTypes: [.state],
            id: "contest4"
        ),
        Contest(
            districtName: "Legislative District No. 34",
            ballotTitle: "Representative Position No. 1",
            jurisdictionTypes: [.state],
            id: "contest5"
        ),
        Contest(
            districtName: "Legislative District No. 36",
            ballotTitle: "Representative Position No. 2",
            jurisdictionTypes: [.state],
            id: "contest6"
        ),
        Contest(
            districtName: "Legislative District No. 36",
            ballotTitle: "Representative Position No. 1",
            jurisdictionTypes: [.state],
            id: "contest7"
        ),
        Contest(
            districtName: "City of Seattle",
            ballotTitle: "Council Position No. 8",
            jurisdictionTypes: [.state],
            id: "contest8"
        ),
        Contest(
            districtName: "City of Seattle",
            ballotTitle: "Council Position No. 9",
            jurisdictionTypes: [.state],
            id: "contest9"
        ),
        Contest(
            districtName: "Federal",
            ballotTitle: "United States Senator",
            jurisdictionTypes: [.county],
            id: "contest10"
        ),
        Contest(
            districtName: "South King Fire",
            ballotTitle: "Proposition No. 1",
            jurisdictionTypes: [.county],
            id: "contest11"
        )
    ]
    
    ContestListView(contests: mockContests)
}
