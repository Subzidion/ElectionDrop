// MARK: - ViewModel

// ElectionService.swift
import Foundation
import Combine

protocol ElectionServiceProtocol: AnyObject {
    var electionsPublisher: AnyPublisher<Set<Election>, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    func fetchElectionUpdate() async
}

actor ElectionService: ElectionServiceProtocol {
    private var elections: Set<Election> = []
    private var isLoading = true
    
    private let electionsSubject = CurrentValueSubject<Set<Election>, Never>([])
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    nonisolated var electionsPublisher: AnyPublisher<Set<Election>, Never> {
        electionsSubject.eraseToAnyPublisher()
    }
    
    nonisolated var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    private func updateElections(_ newElections: Set<Election>) {
        elections = newElections
        Task { @MainActor in
            electionsSubject.send(newElections)
        }
    }
    
    private func updateIsLoading(_ newIsLoading: Bool) {
        isLoading = newIsLoading
        Task { @MainActor in
            isLoadingSubject.send(newIsLoading)
        }
    }
    
    func fetchElectionUpdate() async {
        print("Fetching updates...")
        updateIsLoading(true)
        
        do {
            let urlString = "https://api.electiondrop.app/prod/v1/wa/king-county/election/2024/aug-primary"
            var urlComponents = URLComponents(string: urlString)!
            
            if let currentUpdateCount = await MainActor.run(body: { UserDefaults.standard.string(forKey: "currentUpdateCount") }) {
                urlComponents.queryItems = [URLQueryItem(name: "currentUpdateCount", value: currentUpdateCount)]
            }
            
            let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                updateIsLoading(false)
                return
            }
            
            let jsonData = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            
            if jsonData.isEmpty {
                print("No updates available.")
                updateIsLoading(false)
                return
            }
            
            for item in jsonData {
                if let updateTime = item["UpdateTime"] as? String,
                   let updateCount = item["UpdateCount"] as? String,
                   let csvString = item["ResultCSV"] as? String {
                    await updateElections(updateTime: updateTime, updateCount: updateCount, csvString: csvString)
                }
            }
            
            updateIsLoading(false)
        } catch {
            print("Error fetching election update:", error)
            updateIsLoading(false)
        }
    }
    
    private func updateElections(updateTime: String, updateCount: String, csvString: String) async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        
        guard let updateTime = dateFormatter.date(from: updateTime),
              let updateCount = Int(updateCount) else {
            print("Invalid update time or count")
            return
        }
        
        var updatedElections = self.elections
        var currentUpdate = ElectionUpdate(updateTime: updateTime, updateCount: updateCount, results: [])
        
        let rows = csvString.components(separatedBy: "\r\n")
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 14 else { continue }
            
            let districtName = columns[4]
            let ballotTitle = columns[5]
            let ballotResponse = columns[10]
            let voteCount = columns[12]
            let votePercent = columns[13]
            
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
                let newElection = Election(districtName: districtName, ballotTitle: ballotTitle, updates: [ElectionUpdate(updateTime: updateTime, updateCount: updateCount, results: [newResult])])
                updatedElections.insert(newElection)
            }
            
            currentUpdate.results.append(newResult)
        }
        
        updateElections(updatedElections)
    }
}
