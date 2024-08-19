// MARK: - View

// ElectionResultView.swift
import SwiftUI

struct ElectionResultView: View {
    var result: ElectionResult
    var updateDelta: Text
    var displayFormat: ElectionResultDisplayFormat
    
    var body: some View {
        Group {
            Text(result.ballotResponse)
            Text(displayFormat == .percentOfVote ? String(format: "%.2f%%", result.votePercent) : result.voteCount.formatted())
            updateDelta
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
}
