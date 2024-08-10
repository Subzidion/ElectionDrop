//
//  ElectionResultView.swift
//  ElectionDrop
//
//  Created by Carl Hiltbrunner on 8/9/24.
//

import SwiftUI

struct Result: Identifiable {
    // Represents the Candidate (or Write-in)
    let ballotResponse: String
    let voteCount: String
    let votePercent: String
    var id: String { ballotResponse }
}

struct ElectionResultsView: View {
    var results: [Result]
    
    init(results: [Result]) {
        self.results = results
    }
    
    var body: some View {
        let resultColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        Text("Day 3 Results")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
        LazyVGrid(columns: resultColumns) {
            Group {
                Text("Ballot Response")
                Text("Total Votes")
                Text("Percent of Vote")
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
            .multilineTextAlignment(.center)
            
            ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                Group {
                    Text(result.ballotResponse)
                    Text(result.voteCount)
                    Text(result.votePercent)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
        }
        .padding()
    }
}

#Preview {
    ElectionResultsView(results: [
        Result(ballotResponse: "Shaun Scott", voteCount: "19437", votePercent: "58.97"),
        Result(ballotResponse: "Andrea Suarez", voteCount: "6711", votePercent: "20.36"),
        Result(ballotResponse: "Marie Gluesenkamp Perez", voteCount: "5359", votePercent: "16.29")
    ])
}
