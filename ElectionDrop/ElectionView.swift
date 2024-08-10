//
//  ElectionView.swift
//  ElectionDrop
//
//  Created by Carl Hiltbrunner on 8/9/24.
//

import SwiftUI

struct Election: Identifiable {
    let election: String
    let results: [Result]
    var id: String { election }
}

struct ElectionView: View {
    @State private var results = [
        Result(ballotResponse: "Shaun Scott", voteCount: "19437", votePercent: "58.97"),
        Result(ballotResponse: "Andrea Suarez", voteCount: "6711", votePercent: "20.36"),
        Result(ballotResponse: "Daniel Carusello", voteCount: "5359", votePercent: "16.29")
    ]
    
    var body: some View {
        Image("VoteBox")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: 50)
            .offset(y: -100)
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("State Legislature")
                        .font(.subheadline)
                    Text("43rd District - Position 2")
                        .font(.title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button(action: registerForNotifications) {
                    Image(systemName: "bell")
                        .imageScale(.large)
                        .offset(y: -5)
                }
            }

            Divider()
    
            ElectionResultsView(results: results)
        }
        .padding()
        .background()
    }
}

func registerForNotifications() {
    UIApplication.shared.registerForRemoteNotifications()
}


#Preview {
    ElectionView()
}
