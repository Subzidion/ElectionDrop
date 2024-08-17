// MARK: - Views

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ElectionViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    ElectionListView(elections: viewModel.elections)
                }
            }
            .task {
                await viewModel.loadElectionData()
            }
            .environmentObject(viewModel)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {}
                label: {
                    Image(systemName: "plus")
                }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {}
                label: {
                    Image(systemName: "heart")
                }
                }
            }
        }
    }
}
