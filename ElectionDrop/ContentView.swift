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
                        ProgressView("Loading...")
                    } else {
                        ElectionListView(elections: viewModel.elections)
                    }
                }
            }
            .tag(0)
            
            NavigationStack {
                SettingsView()
            }
            .tag(1)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: { selectedTab = 0 }) {
                        Text("Elections")
                        Image(systemName: "pencil.and.list.clipboard")
                    }
                    Spacer()
                    Button(action: { selectedTab = 1 }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
