// MARK: - Models

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

struct ElectionUpdate: Identifiable, Codable {
    var id = UUID()
    let updateTime: Date
    let updateCount: Int
    var results: [ElectionResult]
}


struct ElectionResult: Identifiable, Codable {
    var id = UUID()
    let ballotResponse: String
    let voteCount: String
    let votePercent: String
}
