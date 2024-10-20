// MARK: - View

import SwiftUI

struct ContestUpdateView: View {
    var currentUpdate: ElectionResultsUpdate
    var previousUpdate: ElectionResultsUpdate?
    var nextUpdate: ElectionResultsUpdate?
    var onPreviousUpdate: (() -> Void)?
    var onNextUpdate: (() -> Void)?
    @AppStorage("contestResultDisplayFormat") private
        var contestResultsDisplayFormat = ContestResultDisplayFormat
        .percentOfVote

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
            Image(
                systemName: direction == .previous
                    ? "chevron.left" : "chevron.right"
            )
            .foregroundColor(
                direction == .previous
                    ? (previousUpdate != nil ? .blue : .gray)
                    : (nextUpdate != nil ? .blue : .gray)
            )
            .imageScale(.large)
            .frame(width: 44, height: 44)
        }
        .disabled(
            direction == .previous ? previousUpdate == nil : nextUpdate == nil)
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
            Text(
                contestResultsDisplayFormat == .percentOfVote
                    ? "% of Vote" : "Vote Count")
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
                ForEach(sortedResults()) { result in
                    ContestResultView(
                        result: result,
                        previousResult: previousUpdate?.results.first(where: {
                            $0.ballotResponseId == result.ballotResponseId
                        }),
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

#Preview {
    let mockContests: [Contest] = [
        Contest(
            districtName: "Congressional District No. 9",
            ballotTitle: "United States Representative",
            jurisdictionTypes: [.county, .state],
            id: "contest1"
        ),
        Contest(
            districtName: "State Executive",
            ballotTitle: "Governor",
            jurisdictionTypes: [.state],
            id: "contest2"
        ),
        Contest(
            districtName: "State",
            ballotTitle: "Justice Position No. 2",
            jurisdictionTypes: [.state],
            id: "contest3"
        ),
        Contest(
            districtName: "Legislative District No. 34",
            ballotTitle: "Representative Position No. 2",
            jurisdictionTypes: [.state],
            id: "contest4"
        ),
        Contest(
            districtName: "Legislative District No. 34",
            ballotTitle: "Representative Position No. 1",
            jurisdictionTypes: [.state],
            id: "contest5"
        ),
        Contest(
            districtName: "Legislative District No. 36",
            ballotTitle: "Representative Position No. 2",
            jurisdictionTypes: [.state],
            id: "contest6"
        ),
        Contest(
            districtName: "Legislative District No. 36",
            ballotTitle: "Representative Position No. 1",
            jurisdictionTypes: [.state],
            id: "contest7"
        ),
        Contest(
            districtName: "City of Seattle",
            ballotTitle: "Council Position No. 8",
            jurisdictionTypes: [.state],
            id: "contest8"
        ),
        Contest(
            districtName: "City of Seattle",
            ballotTitle: "Council Position No. 9",
            jurisdictionTypes: [.state],
            id: "contest9"
        ),
        Contest(
            districtName: "Federal",
            ballotTitle: "United States Senator",
            jurisdictionTypes: [.county],
            id: "contest10"
        ),
        Contest(
            districtName: "South King Fire",
            ballotTitle: "Proposition No. 1",
            jurisdictionTypes: [.county],
            id: "contest11"
        ),
    ]

    ContestListView(contests: mockContests)
}
