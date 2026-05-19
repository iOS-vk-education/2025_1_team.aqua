//
//  RootTabBarController.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 21.11.2025.
//

// 1.0

import SwiftUI
import UIKit

struct MainTabView: View {
    @StateObject private var store = ProductStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var selectedTab = 0
    @State private var historyPath = NavigationPath()

    var body: some View {
        ZStack {
            AppScreenBackground()

            TabView(selection: $selectedTab) {
                NavigationStack(path: $historyPath) {
                    HistoryView(path: $historyPath)
                        .environmentObject(store)
                        .navigationTitle("")
                        .foregroundStyle(Color(hex: "FFED86"))
                        .navigationDestination(for: Product.self) { product in
                            ProductDetailView(product: product)
                        }
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Purely")
                                        .font(.headline.weight(.bold))
                                }
                                .foregroundStyle(.white)
                            }
                        }
                }
                .tag(0)
                .tabItem {
                    Label("История", systemImage: "clock")
                }

                NavigationStack {
                    ScanView(onScanComplete: { product in
                        store.addProduct(product)
                        historyPath.append(product)
                        selectedTab = 0
                    })
                    .environmentObject(store)
                    .navigationTitle("")
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.subheadline.weight(.semibold))
                                Text("Purely")
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                        }
                    }
                }
                .tag(1)
                .tabItem {
                    Label("Сканировать", systemImage: "camera")
                }
            }

            if !hasCompletedOnboarding {
                OnboardingStoriesView {
                    hasCompletedOnboarding = true
                    selectedTab = 1
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
