import SwiftUI

enum ContestGroup: String, CaseIterable, Codable {
    case state = "State"
    case city = "City"
    case federal = "Federal"
    case specialPurposeDistrict = "Special Purpose District"
    
    static func groupContests(_ contests: [Contest], showPCOs: Bool) -> [String: [String: [Contest]]] {
        switch contests.first?.group {
        case .state:
            return groupStateContests(contests, showPCOs: showPCOs)
        case .city, .specialPurposeDistrict:
            return ["": Dictionary(grouping: contests) { $0.districtName }]
        case .federal:
            return ["": Dictionary(grouping: contests) { $0.ballotTitle }]
        case .none:
            return [:]
        }
    }
    
    static func groupStateContests(_ contests: [Contest], showPCOs: Bool) -> [String: [String: [Contest]]] {
        var stateSubGroups: [String: [String: [Contest]]] = [
            "State Legislature": [:],
            "State Executive": [:],
            "State Supreme Court": [:]
        ]
        
        if showPCOs {
            stateSubGroups["Precinct Committee Officer"] = [:]
        }
        
        for contest in contests {
            if showPCOs && contest.districtName.contains("Precinct Committee Officer") {
                stateSubGroups["Precinct Committee Officer"]?[contest.ballotTitle, default: []].append(contest)
            } else if contest.districtName.contains("State Supreme Court") {
                stateSubGroups["State Supreme Court"]?[contest.ballotTitle, default: []].append(contest)
            } else if contest.ballotTitle.contains("Representative") || contest.ballotTitle.contains("State Senator") {
                stateSubGroups["State Legislature"]?[contest.districtName, default: []].append(contest)
            } else {
                stateSubGroups["State Executive"]?[contest.ballotTitle, default: []] = [contest]
            }
        }
        
        return stateSubGroups.filter { !$0.value.isEmpty }
    }
    
    @ViewBuilder
    func view(for subGrouping: String, subGroupData: [String: [Contest]], expandedBinding: @escaping (String) -> Binding<Bool>, isSearching: Bool) -> some View {
        if self == .state {
            CustomDisclosureGroup(
                isExpanded: expandedBinding("\(rawValue)-\(subGrouping)"),
                content: {
                    ForEach(sortedKeys(for: subGrouping, in: subGroupData), id: \.self) { key in
                        if let contests = subGroupData[key], !contests.isEmpty {
                            if subGrouping == "State Legislature" {
                                CustomDisclosureGroup(
                                    isExpanded: expandedBinding("\(rawValue)-\(subGrouping)-\(key)"),
                                    content: {
                                        contestList(contests: contests)
                                    },
                                    label: { Text(key) }
                                )
                                .padding(.leading, 20)
                            } else {
                                contestList(contests: contests)
                            }
                        }
                    }
                },
                label: { Text(subGrouping) }
            )
            .animation(.easeInOut, value: expandedBinding("\(rawValue)-\(subGrouping)").wrappedValue)
        } else {
            ForEach(sortedKeys(for: subGrouping, in: subGroupData), id: \.self) { key in
                if let contest = subGroupData[key], !contest.isEmpty {
                    CustomDisclosureGroup(
                        isExpanded: expandedBinding("\(subGrouping)-\(key)"),
                        content: {
                            contestList(contests: contest)
                        },
                        label: { Text(key) }
                    )
                    .animation(.easeInOut, value: expandedBinding("\(subGrouping)-\(key)").wrappedValue)
                }
            }
        }
    }
    
    private func contestList(contests: [Contest]) -> some View {
        ForEach(contests, id: \.id) { contest in
            ContestRow(contest: contest)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    private func sortedKeys(for subGrouping: String, in subGroupData: [String: [Contest]]) -> [String] {
        return subGroupData.keys.sorted {
            $0.localizedStandardCompare($1) == .orderedDescending
        }
    }
}
