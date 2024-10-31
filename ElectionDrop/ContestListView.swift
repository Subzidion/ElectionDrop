// MARK: - View

import SwiftUI

struct ContestListView: View {
    let contests: [Contest]
    let updates: [ElectionResultsUpdate]
    @State private var searchText = ""
    @State private var expandedSections: Set<String> = []
    @AppStorage("showPCOs") private var showPCOs = true
    
    private var updateCounts: (state: Int, county: Int) {
        let grouped = Dictionary(grouping: updates, by: \.jurisdictionType)
        return (
            state: grouped[.state]?.count ?? 0,
            county: grouped[.county]?.count ?? 0
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                updateCountHeader
                
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
                ContestView(contest: contest, updates: updates)
            }
        }
    }
    
    private var updateCountHeader: some View {
        VStack(spacing: 4) {
            HStack(spacing: 16) {
                UpdateCountPill(
                    count: updateCounts.state,
                    label: "State Updates",
                    color: .blue
                )
                UpdateCountPill(
                    count: updateCounts.county,
                    label: "County Updates",
                    color: .green
                )
            }
            .padding(.vertical, 8)
            
            Divider()
        }
        .background(Color(UIColor.systemBackground))
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

struct UpdateCountPill: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Text("\(count)")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct JurisdictionTag: View {
    let type: JurisdictionType
    
    var body: some View {
        Text(type == .state ? "WA" : "KC")
            .font(.caption2.bold())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(type == .state ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
            .foregroundColor(type == .state ? .blue : .green)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct ContestRow: View {
    let contest: Contest
    
    var body: some View {
        NavigationLink(value: contest) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if contest.ballotTitle == "United States Representative" || contest.ballotTitle.starts(with: "Precinct Committee Officer") {
                        Text(contest.districtName)
                    } else {
                        Text(contest.ballotTitle)
                    }
                }
                .font(.headline)
                .foregroundColor(.primary)
                
                Spacer()
                
                // Add jurisdiction tags
                HStack(spacing: 4) {
                    if let types = contest.jurisdictionTypes {
                        ForEach(types.sorted { $0.rawValue < $1.rawValue }, id: \.self) { type in
                            JurisdictionTag(type: type)
                        }
                    }
                }
            }
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
    ContestListView(contests: MockData.contests, updates: MockData.updates)
}
