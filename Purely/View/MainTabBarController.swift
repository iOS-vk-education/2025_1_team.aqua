//
//  RootTabBarController.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 21.11.2025.
//


// Таббар

import SwiftUI

struct MainTabView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = ProductStore()

    var body: some View {
        TabView {
            NavigationStack {
                HistoryView()
                    .environmentObject(store)
                    .navigationTitle("История")
            }
            .tag(0)
            .tabItem {
                Label("История", systemImage: "clock")
            }

            NavigationStack {
                ScanView()
                    .environmentObject(store)
                    .navigationTitle("Сканирование")
            }
            .tag(1)
            .tabItem {
                Label("Сканировать", systemImage: "camera")
            }
        }
    }
}

#Preview {
    MainTabView()
}
