// MARK: - View

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContestViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading Contests...")
                    } else {
                        ContestListView(contests: viewModel.contests)
                    }
                }
            }
            .tag(0)
            .tabItem {
                Label("Contests", systemImage: "pencil.and.list.clipboard")
            }

            NavigationStack {
                SettingsView()
            }
            .tag(1)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .environmentObject(viewModel)
    }
}
