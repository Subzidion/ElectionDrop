// MARK: - View

// ElectionResultView.swift
import SwiftUI

struct ElectionResultView: View {
    var result: ElectionResult
    var previousResult: ElectionResult?
    var displayFormat: ElectionResultDisplayFormat
    
    var body: some View {
        Text(displayText)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }
    
    private var displayText: String {
        if displayFormat == .percentOfVote {
            return String(format: "%.2f%%", result.votePercent)
        } else {
            return result.voteCount.formatted()
        }
    }
    
    init(result: ElectionResult, previousResult: ElectionResult?, displayFormat: ElectionResultDisplayFormat) {
        self.result = result
        self.previousResult = previousResult
        self.displayFormat = displayFormat
    }
}
