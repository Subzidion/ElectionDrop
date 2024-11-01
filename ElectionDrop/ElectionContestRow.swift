// MARK: - Model

// ElectionContestGroup.swift
import SwiftUI

enum ElectionContestGroup: String, CaseIterable {
    case federal = "Federal"
    case state = "State"
    case judicial = "Judicial"
    case county = "County"
    case city = "City"
    case school = "School"
    case specialPurposeDistrict = "Special Purpose District"
    
    static func groupElectionContests(_ electionContests: [ElectionContest], showPCOs: Bool) -> [String: [String: [ElectionContest]]] {
        switch electionContests.first?.group {
        case .state:
            return groupStateElectionContests(electionContests, showPCOs: showPCOs)
        case .judicial, .county, .city, .school, .specialPurposeDistrict:
            return ["": Dictionary(grouping: electionContests) { $0.districtName }]
        case .federal:
            return ["": Dictionary(grouping: electionContests) { $0.ballotTitle }]
        case .none:
            return [:]
        }
    }
    
    static func groupStateElectionContests(_ electionContests: [ElectionContest], showPCOs: Bool) -> [String: [String: [ElectionContest]]] {
        var stateSubGroups: [String: [String: [ElectionContest]]] = [
            "State Legislature": [:],
            "State Executive": [:],
            "State Supreme Court": [:]
        ]
        
        if showPCOs {
            stateSubGroups["Precinct Committee Officer"] = [:]
        }
        
        for electionContest in electionContests {
            if showPCOs && electionContest.districtType == "Precinct Committee Officer" {
                stateSubGroups["Precinct Committee Officer"]?[electionContest.ballotTitle, default: []].append(electionContest)
            } else if electionContest.districtType == "State Supreme Court" {
                stateSubGroups["State Supreme Court"]?[electionContest.ballotTitle, default: []].append(electionContest)
            } else if electionContest.ballotTitle.contains("Representative") || electionContest.ballotTitle.contains("State Senator") {
                stateSubGroups["State Legislature"]?[electionContest.districtName, default: []].append(electionContest)
            } else {
                stateSubGroups["State Executive"]?[electionContest.ballotTitle, default: []] = [electionContest]
            }
        }
        
        return stateSubGroups.filter { !$0.value.isEmpty }
    }
    
    @ViewBuilder
    func view(for subGrouping: String, subGroupData: [String: [ElectionContest]], expandedBinding: @escaping (String) -> Binding<Bool>, isSearching: Bool) -> some View {
        if self == .state {
            CustomDisclosureGroup(
                isExpanded: expandedBinding("\(rawValue)-\(subGrouping)"),
                content: {
                    ForEach(sortedKeys(for: subGrouping, in: subGroupData), id: \.self) { key in
                        if let electionContests = subGroupData[key], !electionContests.isEmpty {
                            if subGrouping == "State Legislature" {
                                CustomDisclosureGroup(
                                    isExpanded: expandedBinding("\(rawValue)-\(subGrouping)-\(key)"),
                                    content: {
                                        electionContestsList(electionContests: electionContests)
                                    },
                                    label: { Text(key) }
                                )
                                .padding(.leading, 20)
                            } else {
                                electionContestsList(electionContests: electionContests)
                            }
                        }
                    }
                },
                label: { Text(subGrouping) }
            )
            .animation(.easeInOut, value: expandedBinding("\(rawValue)-\(subGrouping)").wrappedValue)
        } else {
            ForEach(sortedKeys(for: subGrouping, in: subGroupData), id: \.self) { key in
                if let electionContests = subGroupData[key], !electionContests.isEmpty {
                    CustomDisclosureGroup(
                        isExpanded: expandedBinding("\(subGrouping)-\(key)"),
                        content: {
                            electionContestsList(electionContests: electionContests)
                        },
                        label: { Text(key) }
                    )
                    .animation(.easeInOut, value: expandedBinding("\(subGrouping)-\(key)").wrappedValue)
                }
            }
        }
    }
    
    private func electionContestsList(electionContests: [ElectionContest]) -> some View {
        ForEach(electionContests.sorted(by: { $0.districtSortKey < $1.districtSortKey }), id: \.id) { electionContest in
            ElectionContestRow(electionContest: electionContest)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    private func sortedKeys(for subGrouping: String, in subGroupData: [String: [ElectionContest]]) -> [String] {
        return subGroupData.keys.sorted {
            subGroupData[$0]?.first?.districtSortKey ?? Int.max < subGroupData[$1]?.first?.districtSortKey ?? Int.max
        }
    }
}
