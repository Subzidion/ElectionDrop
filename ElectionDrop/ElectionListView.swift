// MARK: - View

// ElectionListView.swift
import SwiftUI

struct ElectionListView: View {
    let elections: [Election]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(elections) { election in
                    NavigationLink(value: election) {
                        HStack {
                            Text(election.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                    }
                    Divider()
                }
            }
        }
        .navigationTitle("Elections")
    }
}


#Preview {
    let mockElections: [Election] = [
        Election(title: "2024 August Primary", URL: "https://api.electiondrop.app/prod/v1/wa/king-county/election/2024/aug-primary", contests: []),
        Election(title: "2024 November General", URL: "https://api.electiondrop.app/prod/v1/wa/king-county/election/2024/nov-general", contests: [])
    ]
    
    return ElectionListView(elections: mockElections)
}

