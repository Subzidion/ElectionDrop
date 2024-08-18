// MARK: - View

// SettingsView.swift
import SwiftUI

enum ElectionResultDisplayFormat: String, CaseIterable {
    case percentOfVote = "Percent of Vote"
    case totalVotes = "Total Votes"
}

struct SettingsView: View {
    @AppStorage("showPCOs") private var showPCOs = false
    @AppStorage("showKingCountyOnly") private var showKingCountyOnly = true
    @AppStorage("electionResultDisplayFormat") private var electionResultDisplayFormat = ElectionResultDisplayFormat.percentOfVote
    
    var body: some View {
        Form {
            Section(header: Text("Display Settings")) {
                VStack(alignment: .leading) {
                    Toggle("Show PCO Elections", isOn: $showPCOs)
                    Text("Display Precinct Committee Officers elections.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Toggle("Show King County Only", isOn: $showKingCountyOnly)
                }
                
                VStack(alignment: .leading) {
                    Picker("Results Format", selection: $electionResultDisplayFormat) {
                        ForEach(ElectionResultDisplayFormat.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Extension to allow @AppStorage to work with our custom enum
extension ElectionResultDisplayFormat: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case "Percent of Vote": self = .percentOfVote
        case "Total Votes": self = .totalVotes
        default: return nil
        }
    }
}