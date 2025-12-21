//
//  HistoryView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 19.12.2025.
//

import SwiftUI

struct HistoryView: View {
    private let products: [Product] = [
        Product(
            name: "Шампунь",
            score: 87,
            ingredients: [
                Ingredient(
                    name: "Sodium Laureth Sulfate",
                    role: "ПАВ / очищение",
                    impact: "Может сушить кожу головы и усиливать раздражение при чувствительной коже.",
                    riskLevel: .medium
                ),
                Ingredient(
                    name: "Panthenol",
                    role: "Увлажнение",
                    impact: "Поддерживает барьер кожи, уменьшает ощущение сухости.",
                    riskLevel: .low
                )
            ],
            fullINCI: "Aqua, Sodium Laureth Sulfate, Cocamidopropyl Betaine, Panthenol..."
        ),
        Product(
            name: "Гель для душа",
            score: 74,
            ingredients: [
                Ingredient(
                    name: "Parfum",
                    role: "Отдушка",
                    impact: "Может провоцировать чувствительность кожи.",
                    riskLevel: .medium
                ),
                Ingredient(
                    name: "Glycerin",
                    role: "Увлажнение",
                    impact: "Удерживает влагу и смягчает кожу.",
                    riskLevel: .low
                )
            ],
            fullINCI: "Aqua, Glycerin, Cocamidopropyl Betaine, Parfum..."
        )
    ]

    var body: some View {
        ZStack {
//            Color(hex: "B55BE0")
//                .ignoresSafeArea()
            VStack(spacing: 22) {
                ForEach(products) { product in
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
