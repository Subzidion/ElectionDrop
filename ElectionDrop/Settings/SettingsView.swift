// MARK: - View

// SettingsView.swift
import SwiftUI
import ElectionsGQL

struct SettingsView: View {
    @AppStorage("showPCOs") private var showPCOs = false
    @AppStorage("showKingCountyOnly") private var showKingCountyOnly = true
    @AppStorage("contestResultDisplayFormat") private
    var contestResultDisplayFormat = ContestResultDisplayFormat
        .percentOfVote
    @AppStorage("selectedElectionId") private var selectedElectionId = ""

    @State private var elections: [ElectionsQuery.Data.AllElections.Node] = []
    @State private var isLoadingElections = false
    
    @EnvironmentObject private var viewModel: ContestViewModel

    var body: some View {
        Form {
            Section(header: Text("Election Selection")) {
                if isLoadingElections {
                    ProgressView()
                } else if elections.isEmpty {
                    Text("No elections available")
                        .foregroundColor(.secondary)
                } else {
                    Picker("Select Election", selection: $selectedElectionId) {
                        ForEach(elections, id: \.id) { election in
                            Text(election.name!)
                        }
                    }.onChange(of: selectedElectionId) {
                        Task {
                            await viewModel.loadElectionData(for: selectedElectionId)
                        }
                    }
                }
            }
            Section(header: Text("Display Settings")) {
                VStack(alignment: .leading) {
                    Toggle("Show PCO Elections", isOn: $showPCOs)
                    Text("Display Precinct Committee Officers elections.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading) {
                    Toggle(
                        "Show King County Races Only", isOn: $showKingCountyOnly
                    )
                    Text(
                        """
                        This app only shows election results for King County. By default, state-wide races are hidden since they will show incomplete data.
                        If you want to see the performance for a state-wide race in King County, toggle this off.
                        """
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                VStack(alignment: .leading) {
                    Picker(
                        "Results Format", selection: $contestResultDisplayFormat
                    ) {
                        ForEach(ContestResultDisplayFormat.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// Extension to allow @AppStorage to work with our custom enum
extension ContestResultDisplayFormat: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case "Percent of Vote": self = .percentOfVote
        case "Total Votes": self = .totalVotes
        default: return nil
        }
    }
}
