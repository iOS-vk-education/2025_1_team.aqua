//
//  ProductDetailView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 20.12.2025.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text(product.name)
                    .font(.title.bold())

                // Рейтинг
                HStack(spacing: 12) {
                    Text("Рейтинг")
                        .font(.headline)

                    Spacer()

                    Text("\(product.score)")
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(scoreColor(product.score).opacity(0.15))
                        .foregroundStyle(scoreColor(product.score))
                        .clipShape(Capsule())
                }

                // Основные компоненты
                VStack(alignment: .leading, spacing: 10) {
                    Text("Основные компоненты")
                        .font(.headline)

                    ForEach(product.ingredients) { ing in
                        IngredientCard(ingredient: ing)
                    }
                }

                // Полный состав
                VStack(alignment: .leading, spacing: 8) {
                    Text("Полный состав (INCI)")
                        .font(.headline)

                    Text(product.fullINCI)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "B55BE0").opacity(0.08).ignoresSafeArea())
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0...40:   return .red
        case 41...75:  return .orange
        default:       return .green
        }
    }
}

private struct IngredientCard: View {
    let ingredient: Ingredient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ingredient.name)
                    .font(.headline)

                Spacer()

                Text(ingredient.riskLevel.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(ingredient.riskLevel.color.opacity(0.15))
                    .foregroundStyle(ingredient.riskLevel.color)
                    .clipShape(Capsule())
            }

            Text(ingredient.role)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(ingredient.impact)
                .font(.subheadline)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}


#Preview {
    NavigationStack {
        ProductDetailView(product: .mock)
    }
}
