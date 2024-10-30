// MARK: - View

import SwiftUI

struct ContestView: View {
    enum MoveDirection {
        case forward, backward, none
    }
    
    let contest: Contest
    let updates: [ElectionResultsUpdate]
    @State private var currentUpdateIndex: Int = 0
    @State private var moveDirection: MoveDirection = .none
    @State private var selectedJurisdiction: JurisdictionType = .county
    
    private var filteredUpdates: [ElectionResultsUpdate] {
        updates.filter { $0.jurisdictionType == selectedJurisdiction }
    }
    
    private var hasMultipleJurisdictions: Bool {
        guard let types = contest.jurisdictionTypes else { return false }
        return types.count > 1
    }
    
    private var safeCurrentIndex: Int {
        min(currentUpdateIndex, max(filteredUpdates.count - 1, 0))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(contest.ballotTitle)
                        .font(.title)
                    Text(contest.districtName)
                        .font(.subheadline)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
            
            if hasMultipleJurisdictions {
                Picker("Jurisdiction", selection: $selectedJurisdiction) {
                    Text("County").tag(JurisdictionType.county)
                    Text("State").tag(JurisdictionType.state)
                }
                .pickerStyle(.segmented)
                .padding(.vertical)
            }
            
            Divider()
            
            if !filteredUpdates.isEmpty {
                ContestUpdateView(
                    contest: contest,
                    currentUpdate: filteredUpdates[safeCurrentIndex],
                    previousUpdate: safeCurrentIndex > 0 ? filteredUpdates[safeCurrentIndex - 1] : nil,
                    nextUpdate: currentUpdateIndex < filteredUpdates.count - 1 ? filteredUpdates[safeCurrentIndex + 1] : nil,
                    onPreviousUpdate: {
                        decrementUpdate()
                    },
                    onNextUpdate: {
                        incrementUpdate()
                    }
                )
            } else {
                Text("No updates available for \(selectedJurisdiction.rawValue.lowercased()) jurisdiction")
                    .padding()
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedJurisdiction) {
            // Reset the current update index when switching jurisdictions
            currentUpdateIndex = 0
        }
    }
    
    private func incrementUpdate() {
        if safeCurrentIndex < filteredUpdates.count - 1 {
            moveDirection = .forward
            withAnimation {
                currentUpdateIndex += 1
            }
        }
    }
    
    private func decrementUpdate() {
        if safeCurrentIndex > 0 {
            moveDirection = .backward
            withAnimation {
                currentUpdateIndex -= 1
            }
        }
    }
}

#Preview("Contest View") {
    ContestView(
        contest: MockData.contests[0],
        updates: MockData.updates
    )
}
