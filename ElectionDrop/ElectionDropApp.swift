// MARK: - App

// ElectionDropApp.swift
import SwiftUI

@main
struct ElectionDropApp: App {
    @StateObject private var viewModel = ContestViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .task {
                    await viewModel.loadElectionData()
                }
        }
    }
}
