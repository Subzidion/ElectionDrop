// MARK: - Views

// ElectionView.swift
import SwiftUI

struct ElectionView: View {
    let election: Election
    @State private var currentUpdateIndex: Int
    
    init(election: Election) {
        self.election = election
        self._currentUpdateIndex = State(initialValue: election.updates.count - 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Image("VoteBox")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 50)
                    .offset(y: -100)
                
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text(election.ballotTitle)
                                .font(.title)
                            Text(election.districtName)
                                .font(.subheadline)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    }
                    
                    Divider()
                    
                    if !election.updates.isEmpty {
                        ElectionUpdateView(update: election.updates[currentUpdateIndex])
                    } else {
                        Text("No updates available")
                    }
                }
                .padding()
                .background()
            }
            .overlay(
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            decrementUpdate()
                        }
                    
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            incrementUpdate()
                        }
                }
            )
        }
    }
    
    private func incrementUpdate() {
        if currentUpdateIndex < election.updates.count - 1 {
            currentUpdateIndex += 1
        }
    }
    
    private func decrementUpdate() {
        if currentUpdateIndex > 0 {
            currentUpdateIndex -= 1
        }
    }
}
