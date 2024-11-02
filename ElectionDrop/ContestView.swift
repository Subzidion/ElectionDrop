// MARK: - View

import SwiftUI

struct ContestView: View {
    let contest: Contest
    let updates: [ElectionResultsUpdate]
    @State private var currentUpdateIndex: Int = 0
    @State private var moveDirection: MoveDirection = .none
    @State private var selectedJurisdiction: JurisdictionType
    @State private var isRefreshing = false
    
    var onRefresh: (() async -> Void)?
    
    enum MoveDirection {
        case forward, backward, none
    }
    
    init(contest: Contest, updates: [ElectionResultsUpdate], onRefresh: (() async -> Void)? = nil) {
        self.contest = contest
        self.updates = updates
        self.onRefresh = onRefresh
        let oneJurisdiction = contest.jurisdictionTypes?.count == 1
        let initialJurisdiction = oneJurisdiction ? contest.jurisdictionTypes!.first! : .county
        _selectedJurisdiction = State(initialValue: initialJurisdiction)
    }
    
    private var filteredUpdates: [ElectionResultsUpdate] {
        updates.filter { $0.jurisdictionType == selectedJurisdiction }
    }
    
    private var safeCurrentIndex: Int {
        min(currentUpdateIndex, max(filteredUpdates.count - 1, 0))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    HStack(spacing: 8) {
                        Text(contest.ballotTitle)
                            .font(.title)
                        if let types = contest.jurisdictionTypes {
                            HStack(spacing: 4) {
                                ForEach(types.sorted { $0.rawValue < $1.rawValue }, id: \.self) { type in
                                    JurisdictionTag(type: type)
                                }
                            }
                        }
                    }
                    Text(contest.districtName)
                        .font(.subheadline)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
            
            Picker("Jurisdiction", selection: $selectedJurisdiction) {
                Text("King County Elections")
                    .tag(JurisdictionType.county)
                    .disabled(!(contest.jurisdictionTypes?.contains(.county) ?? true))
                Text("WA State Elections")
                    .tag(JurisdictionType.state)
                    .disabled(!(contest.jurisdictionTypes?.contains(.state) ?? true))
            }
            .disabled(contest.jurisdictionTypes?.count == 1)
            .pickerStyle(.segmented)
            .padding(.vertical)
            
            Divider()
            
            if !filteredUpdates.isEmpty {
                ContestUpdateView(
                    contest: contest,
                    currentUpdate: filteredUpdates[safeCurrentIndex],
                    previousUpdate: safeCurrentIndex > 0 ? filteredUpdates[safeCurrentIndex - 1] : nil,
                    nextUpdate: safeCurrentIndex < filteredUpdates.count - 1 ? filteredUpdates[safeCurrentIndex + 1] : nil,
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        isRefreshing = true
                        await onRefresh?()
                        isRefreshing = false
                    }
                } label: {
                    if isRefreshing {
                        ProgressView()
                            .tint(.accentColor)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .disabled(isRefreshing)
            }
        }
        .onChange(of: selectedJurisdiction) {
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
