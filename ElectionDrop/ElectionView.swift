// MARK: - Views

// ElectionView.swift
import SwiftUI

struct ElectionView: View {
    let elections: Set<Election>
    let election: Election
    
    init(elections: Set<Election>) {
        self.elections = elections
        let district = "Legislative District No. 43"
        let ballot = "Representative Position No. 2"
        self.election = elections.first(where: { $0.districtName == district && $0.ballotTitle == ballot })!
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
                
                ElectionUpdateView(update: election.updates.last!)
            }
            .padding()
            .background()
        }
    }
}
