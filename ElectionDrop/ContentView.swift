// MARK: - Views

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ElectionViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                ElectionView(elections: viewModel.elections)
            }
        }
        .task {
            await viewModel.loadElectionData()
        }
        .environmentObject(viewModel)
    }
}
