// MARK: - View

// ElectionUpdateView.swift
import SwiftUI

struct ElectionUpdateView: View {
    var currentUpdate: ElectionUpdate
    var previousUpdate: ElectionUpdate?
    var nextUpdate: ElectionUpdate?
    var onPreviousUpdate: (() -> Void)?
    var onNextUpdate: (() -> Void)?
    @AppStorage("electionResultDisplayFormat") private var electionResultDisplayFormat = ElectionResultDisplayFormat.percentOfVote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button(action: {
                    if previousUpdate != nil {
                        onPreviousUpdate?()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(previousUpdate != nil ? .blue : .gray)
                }
                .disabled(previousUpdate == nil)
                
                Spacer()
                
                VStack {
                    Text("\(currentUpdate.formattedUpdateDate()) Results")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Results dropped at \(currentUpdate.formattedUpdateTime())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if nextUpdate != nil {
                        onNextUpdate?()
                    }
                }) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(nextUpdate != nil ? .blue : .gray)
                }
                .disabled(nextUpdate == nil)
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Text("Ballot Response")
                        Spacer()
                        Text(electionResultDisplayFormat == .percentOfVote ? "Percent of Vote" : "Vote Count")
                        Spacer()
                        Text("Change")
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                    .padding(.horizontal)
                    
                    ForEach(sortedResults(), id: \.ballotResponse) { result in
                        HStack {
                            Text(result.ballotResponse)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            ElectionResultView(
                                result: result,
                                previousResult: previousUpdate?.results.first(where: { $0.ballotResponse == result.ballotResponse }),
                                displayFormat: electionResultDisplayFormat
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Spacer()
                            
                            updateDelta(for: result)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal)
                        .frame(height: 44)
                    }
                }
            }
        }
    }
    
    private func sortedResults() -> [ElectionResult] {
        currentUpdate.results.sorted { $0.voteCount > $1.voteCount }
    }
    
    private func updateDelta(for result: ElectionResult) -> some View {
        guard let previousResult = previousUpdate?.results.first(where: { $0.ballotResponse == result.ballotResponse }) else {
            return Text("-")
        }
        
        if electionResultDisplayFormat == .percentOfVote {
            let percentDelta = ((result.votePercent - previousResult.votePercent) / previousResult.votePercent) * 100
            let formattedPercentDelta = String(format: "%.2f%%", abs(percentDelta))
            if  percentDelta > 0 {
                return Text("↑\(formattedPercentDelta)").foregroundStyle(.green)
            } else if percentDelta < 0 {
                return Text("↓\(formattedPercentDelta)").foregroundStyle(.red)
            } else {
                return Text("\(formattedPercentDelta)")
            }
        } else {
            let countDelta = result.voteCount - previousResult.voteCount
            let formattedCountDelta = abs(countDelta).formatted()
            if countDelta > 0 {
                return Text("↑\(formattedCountDelta)").foregroundStyle(.green)
            } else if countDelta < 0 {
                return Text("↓\(formattedCountDelta)").foregroundStyle(.red)
            } else {
                return Text("0")
            }
        }
    }
}
