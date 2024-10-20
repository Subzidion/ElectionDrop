// MARK: - View

// SettingsView.swift
import SwiftUI
import ElectionsGQL

struct SettingsView: View {
    let updateContests: () async -> Void
    
    @State private var loadingElections = false
    @State private var elections: [ElectionsQuery.Data.AllElections.Node] = []
    
    @AppStorage("showPCOs") private var showPCOs = false
    @AppStorage("showKingCountyOnly") private var showKingCountyOnly = true
    @AppStorage("contestResultDisplayFormat") private
    var contestResultDisplayFormat = ContestResultDisplayFormat
        .percentOfVote
    @AppStorage("selectedElectionId") private var selectedElectionId = ""

    var body: some View {
        Form {
            Section(header: Text("Election Selection")) {
                if loadingElections {
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
                        selectedElectionId = selectedElectionId
                        Task {
                            await updateContests()
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
            self.loadingElections = true
            Network.shared.apollo.fetch(query: ElectionsQuery()) { result in
                self.loadingElections = false
                switch result {
                case .success(let graphQLResult):
                    if let nodes = graphQLResult.data?.allElections?.nodes {
                        self.elections = nodes.compactMap({ $0 })
                    }
                case .failure(let error):
                    // FIXME: Add error display
                    print(error)
                }
            }
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
