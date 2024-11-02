import ElectionsGQL
import Foundation

struct Contest: Identifiable, Hashable, Codable {
    let districtName: String
    let ballotTitle: String
    let jurisdictionTypes: [JurisdictionType]?
    let ballotResponses: [BallotResponse]
    var id: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var group: ContestGroup {
        return .city
    }
    
    static func == (lhs: Contest, rhs: Contest) -> Bool {
        lhs.id == rhs.id
    }
    
    static func fromGqlResponse(
        from gqlContest: ContestData
    ) -> Contest {
        return Contest(
            districtName: gqlContest.district!,
            ballotTitle: gqlContest.ballotTitle!,
            jurisdictionTypes: gqlContest.jurisdictions!.compactMap({
                JurisdictionType(rawValue: $0!)
            }),
            ballotResponses: gqlContest.ballotResponsesByContestId.nodes.compactMap({
                BallotResponse.fromGqlResponse(from: $0!)
            }),
            id: gqlContest.id
        )
    }
    
    var isPCO: Bool {
        return self.ballotTitle.contains("Precinct Committee Officer")
    }
    
}

struct BallotResponse: Identifiable, Codable, Equatable {
    let id: String
    let response: String
    let party: String

    static func fromGqlResponse(
        from gqlResponse: ContestData.BallotResponsesByContestId.Node
    ) -> BallotResponse {
        return BallotResponse(
            id: gqlResponse.id,
            response: gqlResponse.name!,
            party: gqlResponse.party!
        )
    }
}

struct ElectionResultsUpdate: Identifiable, Codable, Equatable {
    let id: String
    let updateTime: Date
    let hash: String
    let jurisdictionType: JurisdictionType
    var results: [ContestResult]

    static func == (lhs: ElectionResultsUpdate, rhs: ElectionResultsUpdate)
        -> Bool
    {
        lhs.id == rhs.id && lhs.updateTime == rhs.updateTime
    }

    func getResults(for ballotResponseId: String) -> [ContestResult] {
        return results.filter {
            $0.ballotResponseId == ballotResponseId
        }
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
        let dateInPST = updateTime.addingTimeInterval(
            TimeInterval(timeZone.secondsFromGMT(for: updateTime)))

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

    static func fromGqlResponse(
        from gqlUpdate: UpdateData
    ) -> ElectionResultsUpdate {
        let voteTallies = gqlUpdate.voteTalliesByUpdateId.nodes.compactMap({
            node -> ContestResult? in
            guard let id = node?.id,
                let ballotResponseId = node?.ballotResponseId,
                let votes = Int(node?.votes ?? ""),
                let votePercentage = Float(node?.votePercentage ?? "")
            else {
                return nil
            }
            return ContestResult(
                id: id,
                ballotResponseId: ballotResponseId,
                voteCount: votes,
                votePercent: votePercentage
            )
        })

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return ElectionResultsUpdate(
            id: gqlUpdate.id,
            updateTime: dateFormatter.date(from: gqlUpdate.timestamp!)!,
            hash: gqlUpdate.hash!,
            jurisdictionType: JurisdictionType(
                rawValue: gqlUpdate.jurisdictionType!)!,
            results: voteTallies
        )
    }
}

struct ContestResult: Identifiable, Codable, Equatable {
    let id: String
    let ballotResponseId: String
    let voteCount: Int
    let votePercent: Float

    static func == (lhs: ContestResult, rhs: ContestResult) -> Bool {
        lhs.id == rhs.id && lhs.ballotResponseId == rhs.ballotResponseId
            && lhs.voteCount == rhs.voteCount
            && lhs.votePercent == rhs.votePercent
    }
}

enum ContestResultDisplayFormat: String, CaseIterable {
    case percentOfVote = "Percent of Vote"
    case totalVotes = "Total Votes"
}
