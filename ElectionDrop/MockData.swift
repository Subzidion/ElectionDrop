//
//  MockData.swift
//  ElectionDrop
//
//  Created by Daniel Heppner on 10/29/24.
//


// MARK: - Mock Data

import Foundation

struct MockData {
    static let ballotResponses: [BallotResponse] = [
        BallotResponse(id: "candidate_a", response: "Jane Smith", party: "Democratic"),
        BallotResponse(id: "candidate_b", response: "John Doe", party: "Republican"),
        BallotResponse(id: "candidate_c", response: "Sarah Wilson", party: "Independent")
    ]
    
    static let contests: [Contest] = [
        Contest(
            districtName: "Congressional District No. 9",
            ballotTitle: "United States Representative",
            jurisdictionTypes: [.county, .state],
            ballotResponses: ballotResponses,
            id: "contest1"
        ),
        Contest(
            districtName: "State Executive",
            ballotTitle: "Governor",
            jurisdictionTypes: [.state],
            ballotResponses: ballotResponses,
            id: "contest2"
        ),
        Contest(
            districtName: "State Supreme Court",
            ballotTitle: "Justice Position No. 2",
            jurisdictionTypes: [.state],
            ballotResponses: ballotResponses,
            id: "contest3"
        ),
        Contest(
            districtName: "Legislative District No. 34",
            ballotTitle: "Representative Position No. 2",
            jurisdictionTypes: [.state],
            ballotResponses: ballotResponses,
            id: "contest4"
        ),
        Contest(
            districtName: "City of Seattle",
            ballotTitle: "Council Position No. 8",
            jurisdictionTypes: [.county],
            ballotResponses: ballotResponses,
            id: "contest8"
        )
    ]
    
    static let updates: [ElectionResultsUpdate] = {
        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2024, month: 8, day: 6, hour: 20, minute: 0))!
        
        return [
            ElectionResultsUpdate(
                id: "update1",
                updateTime: baseDate.addingTimeInterval(-7200), // 2 hours ago
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
                updateTime: baseDate.addingTimeInterval(-3600), // 1 hour ago
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
                updateTime: baseDate,
                hash: "hash3",
                jurisdictionType: .county,
                results: [
                    ContestResult(id: "result7", ballotResponseId: "candidate_a", voteCount: 16500, votePercent: 45.8),
                    ContestResult(id: "result8", ballotResponseId: "candidate_b", voteCount: 12500, votePercent: 34.7),
                    ContestResult(id: "result9", ballotResponseId: "candidate_c", voteCount: 7000, votePercent: 19.5)
                ]
            )
        ]
    }()
}
