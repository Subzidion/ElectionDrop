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

#Preview("Contest View") {
    ContestView(
        contest: MockData.contests[0],
        updates: MockData.updates
    )
}
