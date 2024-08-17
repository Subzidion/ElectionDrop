// MARK: - View

// ElectionView.swift
import SwiftUI

struct ElectionView: View {
    let election: Election
    @State private var currentUpdateIndex: Int
    @State private var moveDirection: MoveDirection = .none
    
    enum MoveDirection {
        case forward, backward, none
    }
    
    init(election: Election) {
        self.election = election
        self._currentUpdateIndex = State(initialValue: election.updates.count - 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
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
                            .id(currentUpdateIndex)
                            .transition(.asymmetric(
                                insertion: .move(edge: moveDirection == .forward ? .trailing : .leading),
                                removal: .move(edge: moveDirection == .forward ? .leading : .trailing)
                            ))
                            .animation(.easeInOut, value: currentUpdateIndex)
                    } else {
                        Text("No updates available")
                    }
                }
                .padding()
                .padding(.top)
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
            moveDirection = .forward
            withAnimation {
                currentUpdateIndex += 1
            }
        }
    }
    
    private func decrementUpdate() {
        if currentUpdateIndex > 0 {
            moveDirection = .backward
            withAnimation {
                currentUpdateIndex -= 1
            }
        }
    }
}
