// MARK: - ViewModel

// ElectionService.swift
import Foundation

protocol ElectionServiceProtocol: AnyObject {
    func fetchElectionUpdate() async
    func getElections() async -> Set<Election>
}

actor ElectionService: ElectionServiceProtocol {
    private var elections: Set<Election> = []
    private var currentUpdateCount: String?
    
    func getElections() -> Set<Election> {
        return elections
    }
    
    func fetchElectionUpdate() async {
        print("Fetching updates...")
        
        do {
            let urlString = "https://api.electiondrop.app/prod/v1/wa/king-county/election/2024/aug-primary"
            var urlComponents = URLComponents(string: urlString)!
            
            if let currentUpdateCount = currentUpdateCount {
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
            
            var updatedElections = self.elections
            
            for item in jsonData {
                if let updateTime = item["UpdateTime"] as? String,
                   let updateCount = item["UpdateCount"] as? String,
                   let csvString = item["ResultCSV"] as? String {
                    updatedElections = await updateElectionWithResults(updateTime: updateTime, updateCount: updateCount, csvString: csvString, currentElections: updatedElections)
                    
                    currentUpdateCount = updateCount
                }
            }
            
            elections = updatedElections
            print("Election updates complete.")
        } catch {
            print("Error fetching election update:", error)
        }
    }
    
    private func updateElectionWithResults(updateTime: String, updateCount: String, csvString: String, currentElections: Set<Election>) async -> Set<Election> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        
        guard let updateTime = dateFormatter.date(from: updateTime),
              let updateCount = Int(updateCount) else {
            print("Invalid update time or count")
            return currentElections
        }
        
        var updatedElections = currentElections
        var currentUpdate = ElectionUpdate(updateTime: updateTime, updateCount: updateCount, results: [])
        
        let rows = csvString.components(separatedBy: "\r\n")
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 14 else { continue }
            
            let districtSortKey = Int(columns[1].unquoteCSV())!
            let districtType = columns[2].unquoteCSV()
            let treeDistrictType = (districtType == "Precinct Committee Officer" || districtType == "State Supreme Court") ? "State" : districtType
            let districtName = columns[4].unquoteCSV()
            let ballotTitle = columns[5].unquoteCSV()
            let ballotResponse = columns[10].unquoteCSV()
            let voteCount = Int(columns[12].unquoteCSV())!
            let votePercent = Double(columns[13].unquoteCSV())!
            
            let newResult = ElectionResult(ballotResponse: ballotResponse, voteCount: voteCount, votePercent: votePercent)
            
            if var election = updatedElections.first(where: { $0.districtName == districtName && $0.ballotTitle == ballotTitle }) {
                updatedElections.remove(election)
                if var update = election.updates.first(where: { $0.updateCount == updateCount }) {
                    update.results.append(newResult)
                    if let index = election.updates.firstIndex(where: { $0.updateCount == updateCount }) {
                        election.updates[index] = update
                    }
                } else {
                    election.updates.append(ElectionUpdate(updateTime: updateTime, updateCount: updateCount, results: [newResult]))
                }
                updatedElections.insert(election)
            } else {
                let newElection = Election(districtSortKey: districtSortKey, districtName: districtName,
                                           districtType: districtType, treeDistrictType: treeDistrictType, ballotTitle: ballotTitle,
                                           updates: [ElectionUpdate(updateTime: updateTime, updateCount: updateCount, results: [newResult])])
                updatedElections.insert(newElection)
            }
            
            currentUpdate.results.append(newResult)
        }
        
        return updatedElections
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
}
