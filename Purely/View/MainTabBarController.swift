//
//  RootTabBarController.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 21.11.2025.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = ProductStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            AppScreenBackground()

            TabView {
                NavigationStack {
                    HistoryView()
                        .environmentObject(store)
                        .navigationTitle("История")
                        .foregroundStyle(Color(hex: "FFED86"))
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

            if !hasCompletedOnboarding {
                OnboardingStoriesView {
                    hasCompletedOnboarding = true
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            hasCompletedOnboarding = false
        }
    }
}

#Preview {
    MainTabView()
}
