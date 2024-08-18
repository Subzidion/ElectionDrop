// MARK: - View

// ElectionResultView.swift
import SwiftUI

struct ElectionResultView: View {
    var result: ElectionResult
    var displayFormat: ElectionResultDisplayFormat

    
    var body: some View {
        Group {
            Text(result.ballotResponse)
            Text(displayFormat == .percentOfVote ? result.votePercent : result.voteCount)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
}
