//
//  ProductDetailView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 20.12.2025.
//

import SwiftUI
import UIKit

struct ProductDetailView: View {
    let product: Product
    @State private var didCopyComposition = false
    @State private var shareImagePayload: ShareImagePayload?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header карточка
                VStack(alignment: .leading, spacing: 12) {
                    Text(product.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Общий рейтинг")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(product.ratingSummary)
                                .font(.headline)
                                .foregroundStyle(scoreColor(product.score))
                        }

                        Spacer()

                        Text("\(product.score)")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(scoreColor(product.score).opacity(0.15))
                            .foregroundStyle(scoreColor(product.score))
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                // Основные компоненты
                VStack(alignment: .leading, spacing: 12) {
                    Text("Основные компоненты")
                        .font(.headline)

                    VStack(spacing: 10) {
                        ForEach(product.ingredients) { ing in
                            IngredientCard(ingredient: ing)
                        }
                    }
                }

                // Полный состав
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Полный состав (INCI)")
                            .font(.headline)

                        Spacer()

                        Button {
                            UIPasteboard.general.string = product.full_composition
                            withAnimation {
                                didCopyComposition = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    didCopyComposition = false
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                Text("Копировать")
                            }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    Text(product.full_composition)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    if didCopyComposition {
                        Text("Состав скопирован")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let image = ProductShareImageGenerator.makeImage(for: product) {
                        shareImagePayload = ShareImagePayload(image: image)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(item: $shareImagePayload) { payload in
            ShareActivityView(activityItems: [payload.image])
        }
        .scrollContentBackground(.hidden)
        .background { AppScreenBackground() }
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
