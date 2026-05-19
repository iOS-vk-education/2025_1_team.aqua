//
//  HistoryView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 19.12.2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: ProductStore
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            AppScreenBackground()
            List {
                VStack(alignment: .leading, spacing: 10) {
                    Text("История проверок")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowInsets(EdgeInsets(top: 22, leading: 22, bottom: 10, trailing: 22))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                ForEach(store.products) { product in
                    Button {
                        path.append(product)
                    } label: {
                        GlassButton(title: product.name, score: product.score)
                    }
                    .buttonStyle(LiquidPressStyle())
                    .listRowInsets(EdgeInsets(top: 8, leading: 22, bottom: 8, trailing: 22))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.removeProduct(product)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        HistoryView(path: .constant(NavigationPath()))
            .environmentObject(ProductStore())
            .navigationTitle("История")
    }
}

struct LiquidPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
