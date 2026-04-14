//
//  HistoryView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 19.12.2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: ProductStore
    @State private var selectedProduct: Product?

    var body: some View {
        ZStack {
            AppScreenBackground()
            List {
                ForEach(store.products) { product in
                    Button {
                        selectedProduct = product
                    } label: {
                        GlassButton(title: product.name, score: product.score)
                    }
                    .buttonStyle(LiquidPressStyle())
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
//                    .listRowSeparatorTint(Color.white.opacity(0.3))
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
            .navigationDestination(item: $selectedProduct) { product in
                ProductDetailView(product: product)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
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
