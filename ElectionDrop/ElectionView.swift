// MARK: - Views

// ElectionView.swift
import SwiftUI

struct ElectionView: View {
    let election: Election
    @State private var currentUpdateIndex: Int
    
    init(election: Election) {
        self.election = election
        // Initialize with the index of the last update
        self._currentUpdateIndex = State(initialValue: election.updates.count - 1)
    }
    
    var body: some View {
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
                        .gesture(
                            DragGesture(minimumDistance: 50)
                                .onEnded { value in
                                    if value.translation.width < 0 {
                                        // Swipe left
                                        incrementUpdate()
                                    } else if value.translation.width > 0 {
                                        // Swipe right
                                        decrementUpdate()
                                    }
                                }
                        )
                    
                    HStack {
                        Button(action: decrementUpdate) {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(currentUpdateIndex == 0)
                        
                        Spacer()
                        
                        Text("\(currentUpdateIndex + 1) / \(election.updates.count)")
                        
                        Spacer()
                        
                        Button(action: incrementUpdate) {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(currentUpdateIndex == election.updates.count - 1)
                    }
                    .padding(.top)
                } else {
                    Text("No updates available")
                }
            }
            .padding()
            .background()
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
