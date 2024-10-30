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
                                .padding()
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
