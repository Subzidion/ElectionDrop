// MARK: - View

import SwiftUI

struct ContestUpdateView: View {
    var currentUpdate: ContestResultsUpdate
    var previousUpdate: ContestResultsUpdate?
    var nextUpdate: ContestResultsUpdate?
    var onPreviousUpdate: (() -> Void)?
    var onNextUpdate: (() -> Void)?
    @AppStorage("contestResultDisplayFormat") private var contestResultsDisplayFormat = ContestResultDisplayFormat.percentOfVote
    
    var body: some View {
        VStack(spacing: 0) {
            navigationHeader
            resultHeader
            resultList
        }
        .background(Color(.systemBackground))
    }
    
    private var navigationHeader: some View {
        HStack {
            navigationButton(direction: .previous)
            Spacer()
            updateInfo
            Spacer()
            navigationButton(direction: .next)
        }
        .padding()
    }
    
    private func navigationButton(direction: NavigationDirection) -> some View {
        Button(action: {
            direction == .previous ? onPreviousUpdate?() : onNextUpdate?()
        }) {
            Image(systemName: direction == .previous ? "chevron.left" : "chevron.right")
                .foregroundColor(direction == .previous ? (previousUpdate != nil ? .blue : .gray) : (nextUpdate != nil ? .blue : .gray))
                .imageScale(.large)
                .frame(width: 44, height: 44)
        }
        .disabled(direction == .previous ? previousUpdate == nil : nextUpdate == nil)
    }
    
    private var updateInfo: some View {
        VStack(spacing: 4) {
            Text("\(currentUpdate.formattedUpdateDate())")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            Text("Updated at \(currentUpdate.formattedUpdateTime())")
                .font(.subheadline)
        }
        .foregroundColor(.secondary)
    }
    
    private var resultHeader: some View {
        HStack {
            Text("Ballot Response")
                .frame(width: 120, alignment: .leading)
            Spacer()
            Text(contestResultsDisplayFormat == .percentOfVote ? "% of Vote" : "Vote Count")
            Spacer()
            Text("Change")
                .frame(width: 80, alignment: .trailing)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var resultList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sortedResults(), id: \.ballotResponse) { result in
                    ContestResultView(
                        result: result,
                        previousResult: previousUpdate?.results.first(where: { $0.ballotResponse == result.ballotResponse }),
                        displayFormat: contestResultsDisplayFormat
                    )
                    .padding(.horizontal)
                    Divider()
                }
            }
        }
    }
    
    private func sortedResults() -> [ContestResult] {
        currentUpdate.results.sorted { $0.voteCount > $1.voteCount }
    }
}

private enum NavigationDirection {
    case previous, next
}


#Preview("ContestUpdateView") {
    let dateComponents = DateComponents(
        year: 2026,
        month: 9,
        day: 23,
        hour: 12,
        minute: 0,
        second: 0
    )

    let calendar = Calendar.current
    let date = calendar.date(from: dateComponents)!
    
    let sampleCurrentResults = [
        ContestResult(ballotResponse: "Candidate A", voteCount: 14500, votePercent: 44.4),
        ContestResult(ballotResponse: "Candidate B", voteCount: 12000, votePercent: 36.7),
        ContestResult(ballotResponse: "Candidate C", voteCount: 6200, votePercent: 18.9)
    ]
    
    let samplePreviousResults = [
        ContestResult(ballotResponse: "Candidate A", voteCount: 15000, votePercent: 45.5),
        ContestResult(ballotResponse: "Candidate B", voteCount: 12500, votePercent: 37.9),
        ContestResult(ballotResponse: "Candidate C", voteCount: 5500, votePercent: 16.6)
    ]
    
    let sampleNextResults = [
        ContestResult(ballotResponse: "Candidate A", voteCount: 14200, votePercent: 43.8),
        ContestResult(ballotResponse: "Candidate B", voteCount: 11800, votePercent: 36.4),
        ContestResult(ballotResponse: "Candidate C", voteCount: 6400, votePercent: 19.8)
    ]
    
    let currentUpdate = ContestResultsUpdate(
        updateTime: date,
        updateCount: 2,
        results: sampleCurrentResults
    )
    
    let previousUpdate = ContestResultsUpdate(
        updateTime: date.addingTimeInterval(-3600), // 1 hour ago
        updateCount: 1,
        results: samplePreviousResults
    )
    
    let nextUpdate = ContestResultsUpdate(
        updateTime: date.addingTimeInterval(3600), // 1 hour in the future
        updateCount: 3,
        results: sampleNextResults
    )
    
    return ContestUpdateView(
        currentUpdate: currentUpdate,
        previousUpdate: previousUpdate,
        nextUpdate: nextUpdate,
        onPreviousUpdate: { print("Go Back. These dont do anything!") },
        onNextUpdate: { print("Go Forward. These dont do anything in this view!") }
    )
}

