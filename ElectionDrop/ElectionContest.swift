// MARK: - Model

// ElectionContest.swift
import Foundation

struct Election: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var URL: String
    var currentUpdateCount: String?
    var contests: Set<ElectionContest>
}

struct ElectionContest: Identifiable, Hashable, Codable {
    let districtSortKey: Int
    let districtName: String
    let districtType: String
    // A value we compute from the CSV to categorize the Election Contest for the ElectionContestListView
    let treeDistrictType: String
    let ballotTitle: String
    var updates: [ElectionContestUpdate]
    var id: String { districtName + " " + districtType + " " + ballotTitle }
    var group: ElectionContestGroup {
        switch treeDistrictType {
        case "State": return .state
        case "City": return .city
        case "Federal": return .federal
        case "Special Purpose District": return .specialPurposeDistrict
        default: return .specialPurposeDistrict
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ElectionContest, rhs: ElectionContest) -> Bool {
        lhs.id == rhs.id
    }
}

struct ElectionContestUpdate: Identifiable, Codable, Equatable {
    var id = UUID()
    let updateTime: Date
    let updateCount: Int
    var results: [ElectionContestResult]
    
    static func == (lhs: ElectionContestUpdate, rhs: ElectionContestUpdate) -> Bool {
        lhs.id == rhs.id && lhs.updateTime == rhs.updateTime && lhs.updateCount == rhs.updateCount && lhs.results == rhs.results
    }
    
    func formattedUpdateDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        
        let formattedDate = dateFormatter.string(from: updateTime)
        
        let day = Calendar.current.component(.day, from: updateTime)
        let suffix = daySuffix(for: day)
        
        return formattedDate + suffix
    }
    
    func formattedUpdateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        
        let timeString = dateFormatter.string(from: updateTime)
        
        let timeZone = TimeZone(identifier: "America/Los_Angeles")!
        let dateInPST = updateTime.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: updateTime)))
        
        let isDST = timeZone.isDaylightSavingTime(for: dateInPST)
        let zoneAbbreviation = isDST ? "PDT" : "PST"
        
        return "\(timeString) \(zoneAbbreviation)"
    }
    
    private func daySuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}

struct ElectionContestResult: Identifiable, Codable, Equatable {
    var id = UUID()
    let ballotResponse: String
    let voteCount: Int
    let votePercent: Double
    
    static func == (lhs: ElectionContestResult, rhs: ElectionContestResult) -> Bool {
        lhs.id == rhs.id && lhs.ballotResponse == rhs.ballotResponse && lhs.voteCount == rhs.voteCount && lhs.votePercent == rhs.votePercent
    }
}

enum ElectionContestResultDisplayFormat: String, CaseIterable {
    case percentOfVote = "Percent of Vote"
    case totalVotes = "Total Votes"
}
