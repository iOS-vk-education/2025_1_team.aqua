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

    var body: some View {
        TabView {
            NavigationStack {
                HistoryView()
                    .navigationTitle("История")
            }
            .tag(0)
            .tabItem {
                Label("История", systemImage: "clock")
            }

            NavigationStack {
                ScanView()
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
