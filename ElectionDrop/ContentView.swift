// MARK: - View

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ElectionViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading 2024 August Primary Election...")
                    } else {
                        ElectionContestListView(electionContests: viewModel.electionContests)
                    }
                }
            }
            .tag(0)
            .tabItem {
                Label("Elections", systemImage: "pencil.and.list.clipboard")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tag(1)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}
