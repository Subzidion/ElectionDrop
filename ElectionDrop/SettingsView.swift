// MARK: - View

// SettingsView.swift
import SwiftUI

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
                    Toggle("Show King County Races Only", isOn: $showKingCountyOnly)
                    Text("""
                         This app only shows election results for King County. By default, state-wide races are hidden since they will show incomplete data.
                         If you want to see the performance for a state-wide race in King County, toggle this off.
                         """)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
