// MARK: - ViewModel

// ElectionService.swift
import Foundation

protocol ElectionServiceProtocol: AnyObject {
    func fetchElectionUpdate() async
    func getElections() async -> [Election]
}

actor ElectionService: ElectionServiceProtocol {
    private var elections: [Election] = [
        Election(title: "2024 August Primary", URL: "https://api.electiondrop.app/prod/v1/wa/king-county/election/2024/aug-primary", contests: []),
        Election(title: "2024 November General", URL: "https://api.electiondrop.app/prod/v1/wa/king-county/election/2024/nov-general", contests: [])
    ]
    
    func getElections() -> [Election] {
        return elections
    }
    
    func fetchElectionUpdate() async {
        for (index, election) in elections.enumerated() {
            do {
                print("Fetching updates for Election " + election.title)
                let urlString = election.URL
                var urlComponents = URLComponents(string: urlString)!
                
                if let currentUpdateCount = election.currentUpdateCount {
                    urlComponents.queryItems = [URLQueryItem(name: "currentUpdateCount", value: currentUpdateCount)]
                }
                
                let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid response.")
                    return
                }
                
                print("Request complete, parsing response...")
                let jsonData = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
                
                if jsonData.isEmpty {
                    print("No updates returned in response.")
                    return
                }
                
                var updatedElectionContests = election.contests
                var updatedElection = election  // Create a mutable copy of the election
                
                for item in jsonData {
                    if let updateTime = item["UpdateTime"] as? String,
                       let updateCount = item["UpdateCount"] as? String,
                       let csvString = item["ResultCSV"] as? String {
                        updatedElectionContests = await updateElectionContestWithResults(
                            updateTime: updateTime,
                            updateCount: updateCount,
                            csvString: csvString,
                            currentElectionContests: updatedElectionContests
                        )
                        updatedElection.currentUpdateCount = updateCount
                    }
                }
                
                updatedElection.contests = updatedElectionContests
                elections[index] = updatedElection
                print("Election updates complete.")
            } catch {
                print("Error fetching election update:", error)
            }
        }
    }
    
    private func updateElectionContestWithResults(updateTime: String, updateCount: String, csvString: String, currentElectionContests: Set<ElectionContest>) async -> Set<ElectionContest> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        
        guard let updateTime = dateFormatter.date(from: updateTime),
              let updateCount = Int(updateCount) else {
            print("Invalid update time or count")
            return currentElectionContests
        }
        
        var updatedElectionContests = currentElectionContests
        var currentUpdate = ElectionContestUpdate(updateTime: updateTime, updateCount: updateCount, results: [])
        
        let rows = csvString.components(separatedBy: "\r\n")
        for row in rows.dropFirst() {
            let columns = row.csvColumns()
            guard columns.count >= 14 else { continue }
            
            let districtSortKey = Int(columns[1].unquoteCSV())!
            let districtType = columns[2].unquoteCSV()
            var treeDistrictType: String
            if districtType == "Precinct Committee Officer" || districtType == "State Supreme Court" {
                treeDistrictType = "State"
            } else if districtType == "Court of Appeals" || districtType == "Superior Court" || districtType == "District Court" {
                treeDistrictType = "Judicial"
            } else {
                treeDistrictType = districtType
            }
            let districtName = columns[4].unquoteCSV().replacingSuffix(" of the United States", with: "")
            let ballotTitle = columns[5].unquoteCSV().replacingSuffix(" of the United States", with: "")
            let ballotResponse = columns[10].unquoteCSV()
            let voteCount = Int(columns[12].unquoteCSV())!
            let votePercent = Double(columns[13].unquoteCSV())!
            
            let newResult = ElectionContestResult(ballotResponse: ballotResponse, voteCount: voteCount, votePercent: votePercent)
            
            if var electionContest = updatedElectionContests.first(where: { $0.districtName == districtName && $0.ballotTitle == ballotTitle }) {
                updatedElectionContests.remove(electionContest)
                if var update = electionContest.updates.first(where: { $0.updateCount == updateCount }) {
                    update.results.append(newResult)
                    if let index = electionContest.updates.firstIndex(where: { $0.updateCount == updateCount }) {
                        electionContest.updates[index] = update
                    }
                } else {
                    electionContest.updates.append(ElectionContestUpdate(updateTime: updateTime, updateCount: updateCount, results: [newResult]))
                }
                updatedElectionContests.insert(electionContest)
            } else {
                let newElectionContest = ElectionContest(districtSortKey: districtSortKey, districtName: districtName,
                                                         districtType: districtType, treeDistrictType: treeDistrictType, ballotTitle: ballotTitle,
                                                         updates: [ElectionContestUpdate(updateTime: updateTime, updateCount: updateCount, results: [newResult])])
                updatedElectionContests.insert(newElectionContest)
            }
            
            currentUpdate.results.append(newResult)
        }
        
        return updatedElectionContests
    }
}

extension String {
    func unquoteCSV() -> String {
        var result = self
        
        // If the string starts and ends with quotes, remove them
        if result.hasPrefix("\"") && result.hasSuffix("\"") {
            result.removeFirst()
            result.removeLast()
        }
        
        // Replace double quotes with single quotes
        result = result.replacingOccurrences(of: "\"\"", with: "\"")
        
        // Remove leading and trailing whitespace
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    func csvColumns() -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for char in self {
            switch char {
            case "\"":
                insideQuotes.toggle()
            case ",":
                if insideQuotes {
                    currentColumn.append(char)
                } else {
                    columns.append(currentColumn.unquoteCSV())
                    currentColumn = ""
                }
            default:
                currentColumn.append(char)
            }
        }
        
        // Add the last column
        columns.append(currentColumn.unquoteCSV())
        
        return columns
    }
    
    func replacingSuffix(_ suffix: String, with replacement: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count)) + replacement
    }
}
