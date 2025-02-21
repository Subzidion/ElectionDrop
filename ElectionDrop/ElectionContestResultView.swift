// MARK: - View

// ElectionContestResultView.swift
import SwiftUI

struct ElectionContestResultView: View {
    var result: ElectionContestResult
    var previousResult: ElectionContestResult?
    var displayFormat: ElectionContestResultDisplayFormat
    
    var body: some View {
        HStack {
            Text(result.ballotResponse)
                .frame(width: 120, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            Spacer()
            ElectionContestResultRowView(result: result, displayFormat: displayFormat)
            Spacer()
            updateDelta
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 12)
    }
    
    private var updateDelta: some View {
        Group {
            if let previousResult = previousResult {
                let delta = calculateDelta(current: result, previous: previousResult)
                Text(delta.formattedValue)
                    .foregroundColor(delta.color)
            } else {
                Text("-")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func calculateDelta(current: ElectionContestResult, previous: ElectionContestResult) -> (formattedValue: String, color: Color) {
        if displayFormat == .percentOfVote {
            let currentPercent = current.votePercent
            let previousPercent = previous.votePercent
            let percentageDelta = currentPercent - previousPercent
            let percentageChange = (percentageDelta / previousPercent) * 100
            
            let formattedPercentChange = String(format: "%.2f%%", abs(percentageChange))
            let color: Color = percentageChange > 0 ? .green : (percentageChange < 0 ? .red : .primary)
            let prefix = percentageChange > 0 ? "↑" : (percentageChange < 0 ? "↓" : "")
            return ("\(prefix)\(formattedPercentChange)", color)
        } else {
            let countDelta = current.voteCount - previous.voteCount
            let formattedCountDelta = abs(countDelta).formatted()
            let color: Color = countDelta > 0 ? .green : (countDelta < 0 ? .red : .primary)
            let prefix = countDelta > 0 ? "↑" : (countDelta < 0 ? "↓" : "")
            return ("\(prefix)\(formattedCountDelta)", color)
        }
    }
}

struct ElectionContestResultRowView: View {
    var result: ElectionContestResult
    var displayFormat: ElectionContestResultDisplayFormat
    
    var body: some View {
        Text(displayText)
            .fontWeight(.medium)
    }
    
    private var displayText: String {
        if displayFormat == .percentOfVote {
            return String(format: "%.1f%%", result.votePercent)
        } else {
            return result.voteCount.formatted()
        }
    }
}

#Preview("Percent of Vote") {
    let sampleCurrentResult = ElectionContestResult(ballotResponse: "Candidate A", voteCount: 14500, votePercent: 44.4)
    
   let samplePreviousResult = ElectionContestResult(ballotResponse: "Candidate A", voteCount: 15000, votePercent: 45.5)
    
    return ElectionContestResultView(
        result: sampleCurrentResult,
        previousResult: samplePreviousResult,
        displayFormat: .percentOfVote
    )
}
