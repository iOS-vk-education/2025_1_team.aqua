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
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title3.weight(.semibold))
                    Text("Purely")
                        .font(.title3.weight(.bold))
                }
                .foregroundStyle(.white)

                Text(product.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Общий рейтинг
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Общий рейтинг")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))

                            Text(product.ratingSummary)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(scoreColor(product.score))
                        }

                        Spacer(minLength: 8)

                        Text("\(product.score)")
                            .font(.title2.weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(scoreColor(product.score).opacity(0.86))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
                .detailGlassCard(cornerRadius: 18)

                // Описание
                if !product.description.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Описание")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(product.description)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.88))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .detailGlassCard(cornerRadius: 18)
                }

                // Полный состав
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Полный состав (INCI)")
                            .font(.headline)
                            .foregroundStyle(.white)

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
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Text(product.full_composition)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if didCopyComposition {
                        Text("Состав скопирован")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.72))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .detailGlassCard(cornerRadius: 16)

                // Основные компоненты
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Основные компоненты")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Spacer()

                        Text("Риск")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.66))
                    }

                    VStack(spacing: 8) {
                        ForEach(product.ingredients) { ing in
                            IngredientCard(ingredient: ing)
                        }
                    }
                }
                .detailGlassCard(cornerRadius: 18)

                Text("purely · анализ состава косметики")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)

                Spacer(minLength: 24)
            }
            .padding(22)
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
                        .foregroundStyle(.white)
                }
            }
        }
        .sheet(item: $shareImagePayload) { payload in
            ShareActivityView(activityItems: [payload.image])
        }
        .scrollContentBackground(.hidden)
        .tint(.white)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .background { AppScreenBackground() }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0...40:   return .red
        case 41...75:  return Color(hex: "F2FF30")
        default:       return .green
        }
    }
}

private struct IngredientCard: View {
    let ingredient: Ingredient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Text(ingredient.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text(ingredient.riskLevel.rawValue)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ingredient.riskLevel.color.opacity(0.86))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.24), lineWidth: 1)
                    )
            }

            Text(ingredient.role)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))

            Text(ingredient.impact)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension View {
    func detailGlassCard(cornerRadius: CGFloat) -> some View {
        padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
    }
}


#Preview {
    NavigationStack {
        ProductDetailView(product: .mock)
    }
}
