// MARK: - Model

// ElectionGroup.swift
import SwiftUI

enum ElectionGroup: String, CaseIterable {
    case state = "State"
    case city = "City"
    case federal = "Federal"
    case specialPurposeDistrict = "Special Purpose District"
    
    static func groupElections(_ elections: [Election], showPCOs: Bool) -> [String: [String: [Election]]] {
        switch elections.first?.group {
        case .state:
            return groupStateElections(elections, showPCOs: showPCOs)
        case .city, .specialPurposeDistrict:
            return ["": Dictionary(grouping: elections) { $0.districtName }]
        case .federal:
            return ["": Dictionary(grouping: elections) { $0.ballotTitle }]
        case .none:
            return [:]
        }
    }
    
    static func groupStateElections(_ elections: [Election], showPCOs: Bool) -> [String: [String: [Election]]] {
        var stateSubGroups: [String: [String: [Election]]] = [
            "State Legislature": [:],
            "State Executive": [:],
            "State Supreme Court": [:]
        ]
        
        if showPCOs {
            stateSubGroups["Precinct Committee Officer"] = [:]
        }
        
        for election in elections {
            if showPCOs && election.districtType == "Precinct Committee Officer" {
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
    
    @ViewBuilder
    func view(for subGrouping: String, subGroupData: [String: [Election]], expandedBinding: @escaping (String) -> Binding<Bool>, isSearching: Bool) -> some View {
        if self == .state {
            CustomDisclosureGroup(
                isExpanded: expandedBinding("\(rawValue)-\(subGrouping)"),
                content: {
                    ForEach(sortedKeys(for: subGrouping, in: subGroupData), id: \.self) { key in
                        if let elections = subGroupData[key], !elections.isEmpty {
                            CustomDisclosureGroup(
                                isExpanded: expandedBinding("\(rawValue)-\(subGrouping)-\(key)"),
                                content: {
                                    electionsList(elections: elections)
                                },
                                label: { Text(key) }
                            )
                            .padding(.leading, 20)
                        }
                    }
                },
                label: { Text(subGrouping) }
            )
            .animation(.easeInOut, value: expandedBinding("\(rawValue)-\(subGrouping)").wrappedValue)
        } else {
            ForEach(sortedKeys(for: subGrouping, in: subGroupData), id: \.self) { key in
                if let elections = subGroupData[key], !elections.isEmpty {
                    CustomDisclosureGroup(
                        isExpanded: expandedBinding("\(subGrouping)-\(key)"),
                        content: {
                            electionsList(elections: elections)
                        },
                        label: { Text(key) }
                    )
                    .animation(.easeInOut, value: expandedBinding("\(subGrouping)-\(key)").wrappedValue)
                }
            }
        }
    }
    
    private func electionsList(elections: [Election]) -> some View {
        ForEach(elections.sorted(by: { $0.districtSortKey < $1.districtSortKey }), id: \.id) { election in
            ElectionRow(election: election)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    private func sortedKeys(for subGrouping: String, in subGroupData: [String: [Election]]) -> [String] {
        return subGroupData.keys.sorted {
            subGroupData[$0]?.first?.districtSortKey ?? Int.max < subGroupData[$1]?.first?.districtSortKey ?? Int.max
        }
    }
}
