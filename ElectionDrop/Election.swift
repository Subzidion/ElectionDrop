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
    let updateTime: Date
    let updateCount: Int
    var results: [ElectionResult]
    var id: String { updateCount.formatted() }
}


struct ElectionResult: Identifiable, Codable {
    let ballotResponse: String
    let voteCount: String
    let votePercent: String
    var id: String { ballotResponse }
}
