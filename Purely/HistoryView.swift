//
//  HistoryView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 19.12.2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: ProductStore

    var body: some View {
        ZStack {
            Color(hex: "B55BE0").opacity(0.15).ignoresSafeArea()
            VStack(spacing: 22) {
                ForEach(store.products) { product in
                    NavigationLink(value: product) {
                        GlassButton(title: product.name, score: product.score)
                    }
                    .buttonStyle(LiquidPressStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
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
