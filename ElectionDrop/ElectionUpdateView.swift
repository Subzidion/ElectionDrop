// MARK: - View

// ElectionUpdateView.swift
import SwiftUI

struct ElectionUpdateView: View {
    var currentUpdate: ElectionUpdate
    var previousUpdate: ElectionUpdate?
    @AppStorage("electionResultDisplayFormat") private var electionResultDisplayFormat = ElectionResultDisplayFormat.percentOfVote
    
    var body: some View {
        let resultColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Day \(currentUpdate.updateCount) Results")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            ScrollView {
                LazyVGrid(columns: resultColumns) {
                    Group {
                        Text("Ballot Response")
                        Text(electionResultDisplayFormat == .percentOfVote ? "Percent of Vote" : "Vote Count")
                        Text("Change")
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                    .multilineTextAlignment(.center)
                    
                    ForEach(sortedResults()) { result in
                        ElectionResultView(
                            result: result,
                            updateDelta: formatUpdateDelta(for: result),
                            displayFormat: electionResultDisplayFormat
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private func sortedResults() -> [ElectionResult] {
        currentUpdate.results.sorted {
            Int($0.voteCount) > Int($1.voteCount)
        }
    }
    
    private func formatUpdateDelta(for result: ElectionResult) -> Text {
        guard let previousUpdate = previousUpdate,
              let previousResult = previousUpdate.results.first(where: { $0.ballotResponse == result.ballotResponse }) else {
            if(electionResultDisplayFormat == .percentOfVote) {
                return Text("-")
            } else {
                return Text("-")
            }
        }
        
        if(electionResultDisplayFormat == .percentOfVote) {
            let percentDelta = ((result.votePercent - previousResult.votePercent) / previousResult.votePercent) * 100
            let formattedPercentDelta = String(format: "%.2f%%", percentDelta)
            return percentDelta >= 0 ? Text("+\(formattedPercentDelta)").foregroundStyle(.green) : Text(formattedPercentDelta).foregroundStyle(.red)
        } else {
            let countDelta = result.voteCount - previousResult.voteCount
            if(countDelta > 0) {
                return Text(countDelta.formatted()).foregroundStyle(.green)
            } else if(countDelta < 0) {
                return Text(countDelta.formatted()).foregroundStyle(.red)
            } else {
                return Text(countDelta.formatted())
            }
        }

    }
}
