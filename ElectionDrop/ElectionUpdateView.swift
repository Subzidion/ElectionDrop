// MARK: - View

// ElectionUpdateView.swift
import SwiftUI

struct ElectionUpdateView: View {
    var update: ElectionUpdate
    @AppStorage("electionResultDisplayFormat") private var electionResultDisplayFormat = ElectionResultDisplayFormat.percentOfVote
    
    var body: some View {
        let resultColumns = [GridItem(.flexible()), GridItem(.flexible())]
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Day \(update.updateCount) Results")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            ScrollView {
                LazyVGrid(columns: resultColumns) {
                    Group {
                        Text("Ballot Response")
                        Text(electionResultDisplayFormat == .percentOfVote ? "Percent of Vote" : "Vote Count")
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                    .multilineTextAlignment(.center)
                    
                    ForEach(sortedResults()) { result in
                        ElectionResultView(result: result, displayFormat: electionResultDisplayFormat)
                    }
                }
                .padding()
            }
        }
    }
    
    private func sortedResults() -> [ElectionResult] {
        update.results.sorted {
            Int($0.voteCount) ?? 0 > Int($1.voteCount) ?? 0
        }
    }
}
