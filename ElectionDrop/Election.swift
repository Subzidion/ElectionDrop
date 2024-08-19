// MARK: - Model

// Election.swift
import Foundation

struct Election: Identifiable, Hashable, Codable {
    let districtName: String
    let ballotTitle: String
    var updates: [ElectionUpdate]
    var id: String { districtName + " " + ballotTitle }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Election, rhs: Election) -> Bool {
        lhs.id == rhs.id
    }
}

struct ElectionUpdate: Identifiable, Codable, Equatable {
    var id = UUID()
    let updateTime: Date
    let updateCount: Int
    var results: [ElectionResult]
    
    static func == (lhs: ElectionUpdate, rhs: ElectionUpdate) -> Bool {
        lhs.id == rhs.id && lhs.updateTime == rhs.updateTime && lhs.updateCount == rhs.updateCount && lhs.results == rhs.results
    }
}

struct ElectionResult: Identifiable, Codable, Equatable {
    var id = UUID()
    let ballotResponse: String
    let voteCount: Int
    let votePercent: Double
    
    static func == (lhs: ElectionResult, rhs: ElectionResult) -> Bool {
        lhs.id == rhs.id && lhs.ballotResponse == rhs.ballotResponse && lhs.voteCount == rhs.voteCount && lhs.votePercent == rhs.votePercent
    }
}

enum ElectionResultDisplayFormat: String, CaseIterable {
    case percentOfVote = "Percent of Vote"
    case totalVotes = "Total Votes"
}
