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
                        ProgressView("Loading Election Results...")
                    } else {
                        ElectionListView(elections: viewModel.elections)
                    }
                }
                .navigationDestination(for: Election.self) { election in
                    ElectionContestListView(electionContests: election.contests, title: election.title)
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
