// MARK: - View

import SwiftUI

struct ContestView: View {
    let contest: Contest
    let updates: [ElectionResultsUpdate]
    @State private var currentUpdateIndex: Int = 0
    @State private var moveDirection: MoveDirection = .none
    
    enum MoveDirection {
        case forward, backward, none
    }
    
    init(contest: Contest, updates: [ElectionResultsUpdate]) {
        self.contest = contest
        self.updates = updates
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
            
            if !updates.isEmpty {
                ContestUpdateView(
                    contest: contest,
                    currentUpdate: updates[currentUpdateIndex],
                    previousUpdate: currentUpdateIndex > 0 ? updates[currentUpdateIndex - 1] : nil,
                    nextUpdate: currentUpdateIndex < updates.count - 1 ? updates[currentUpdateIndex + 1] : nil,
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
        if currentUpdateIndex < updates.count - 1 {
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
        ElectionResultsUpdate(
            id: "update1",
            updateTime: date.addingTimeInterval(-172800), // 48 hours ago
            hash: "hash1",
            jurisdictionType: .county,
            results: [
                ContestResult(id: "result1", ballotResponseId: "candidate_a", voteCount: 10000, votePercent: 41.7),
                ContestResult(id: "result2", ballotResponseId: "candidate_b", voteCount: 9000, votePercent: 37.5),
                ContestResult(id: "result3", ballotResponseId: "candidate_c", voteCount: 5000, votePercent: 20.8)
            ]
        ),
        ElectionResultsUpdate(
            id: "update2",
            updateTime: date.addingTimeInterval(-86400), // 24 hours ago
            hash: "hash2",
            jurisdictionType: .county,
            results: [
                ContestResult(id: "result4", ballotResponseId: "candidate_a", voteCount: 14000, votePercent: 44.4),
                ContestResult(id: "result5", ballotResponseId: "candidate_b", voteCount: 11500, votePercent: 36.5),
                ContestResult(id: "result6", ballotResponseId: "candidate_c", voteCount: 6000, votePercent: 19.1)
            ]
        ),
        ElectionResultsUpdate(
            id: "update3",
            updateTime: date,
            hash: "hash3",
            jurisdictionType: .county,
            results: [
                ContestResult(id: "result7", ballotResponseId: "candidate_a", voteCount: 16500, votePercent: 45.8),
                ContestResult(id: "result8", ballotResponseId: "candidate_b", voteCount: 12500, votePercent: 34.7),
                ContestResult(id: "result9", ballotResponseId: "candidate_c", voteCount: 7000, votePercent: 19.5)
            ]
        )
    ]

    let sampleContest = Contest(
        districtName: "Sample District",
        ballotTitle: "2024 Mayoral Election",
        jurisdictionTypes: [.county, .state],
        ballotResponses: [],
        id: "contest123"
    )

    ContestView(contest: sampleContest, updates: sampleUpdates)
}
