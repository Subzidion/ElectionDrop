// MARK: - Views

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ElectionViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
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
            }
            .tag(0)
            
            NavigationStack {
                SettingsView()
            }
            .tag(1)
        }
        .environmentObject(viewModel)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button(action: { selectedTab = 0 }) {
                        Image(systemName: "list.bullet")
                        Text("Elections")
                    }
                    Spacer()
                    Button(action: { selectedTab = 1 }) {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    Spacer()
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
