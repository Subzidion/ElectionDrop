// MARK: - View

import SwiftUI

struct ContestView: View {
    let contest: Contest
    @State private var currentUpdateIndex: Int
    @State private var moveDirection: MoveDirection = .none
    
    enum MoveDirection {
        case forward, backward, none
    }
    
    init(contest: Contest) {
        self.contest = contest
        self._currentUpdateIndex = State(initialValue: contest.updates.count - 1)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(contest.ballotTitle)
                        .font(.title)
                    Text(contest.districtName)
                        .font(.subheadline)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
            
            Divider()
            
            if !contest.updates.isEmpty {
                ContestUpdateView(
                    currentUpdate: contest.updates[currentUpdateIndex],
                    previousUpdate: currentUpdateIndex > 0 ? contest.updates[currentUpdateIndex - 1] : nil,
                    nextUpdate: currentUpdateIndex < contest.updates.count - 1 ? contest.updates[currentUpdateIndex + 1] : nil,
                    onPreviousUpdate: {
                        decrementUpdate()
                    },
                    onNextUpdate: {
                        incrementUpdate()
                    }
                )
            } else {
                Text("No updates available")
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func incrementUpdate() {
        if currentUpdateIndex < contest.updates.count - 1 {
            moveDirection = .forward
            withAnimation {
                currentUpdateIndex += 1
            }
        }
    }
    
    private func decrementUpdate() {
        if currentUpdateIndex > 0 {
            moveDirection = .backward
            withAnimation {
                currentUpdateIndex -= 1
            }
        }
    }
}

#Preview("Contest View Preview - Percent of Vote") {
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
    
    let sampleUpdates = [
        ContestResultsUpdate(
            updateTime: date.addingTimeInterval(-172800), // 48 hours ago
            updateCount: 1,
            results: [
                ContestResult(ballotResponse: "Candidate A", voteCount: 10000, votePercent: 41.7),
                ContestResult(ballotResponse: "Candidate B", voteCount: 9000, votePercent: 37.5),
                ContestResult(ballotResponse: "Candidate C", voteCount: 5000, votePercent: 20.8)
            ]
        ),
        ContestResultsUpdate(
            updateTime: date.addingTimeInterval(-86400), // 24 hours ago
            updateCount: 2,
            results: [
                ContestResult(ballotResponse: "Candidate A", voteCount: 14000, votePercent: 44.4),
                ContestResult(ballotResponse: "Candidate B", voteCount: 11500, votePercent: 36.5),
                ContestResult(ballotResponse: "Candidate C", voteCount: 6000, votePercent: 19.1)
            ]
        ),
        ContestResultsUpdate(
            updateTime: date,
            updateCount: 3,
            results: [
                ContestResult(ballotResponse: "Candidate A", voteCount: 16500, votePercent: 45.8),
                ContestResult(ballotResponse: "Candidate B", voteCount: 12500, votePercent: 34.7),
                ContestResult(ballotResponse: "Candidate C", voteCount: 7000, votePercent: 19.5)
            ]
        )
    ]

    let sampleContest = Contest(
        districtSortKey: 1,
        districtName: "Sample District",
        districtType: "City",
        treeDistrictType: "City",
        ballotTitle: "2024 Mayoral Election",
        updates: sampleUpdates
    )

    return ContestView(contest: sampleContest)
}
