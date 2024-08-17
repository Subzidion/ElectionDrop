// MARK: - View

// ElectionResultView.swift
import SwiftUI

struct ElectionResultView: View {
    var result: ElectionResult
    
    var body: some View {
        Group {
            Text(result.ballotResponse)
            Text(result.voteCount)
            Text(result.votePercent)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
}
