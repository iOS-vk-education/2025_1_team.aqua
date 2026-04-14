//
//  ProductShareCard.swift
//  Purely
//


import SwiftUI
import UIKit

// Верстка Карточки

struct ProductShareCardView: View {
    let product: Product

    private let cardWidth: CGFloat = 390
    private let maxIngredientsOnCard = 12

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "B55BE0"), Color(hex: "6C4AB6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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
                    .fixedSize(horizontal: false, vertical: true)

                ratingBlock

                VStack(alignment: .leading, spacing: 10) {
                    Text("Основные компоненты")
                        .font(.headline)
                        .foregroundStyle(.white)

                    VStack(spacing: 8) {
                        ForEach(ingredientsToShow) { ing in
                            shareIngredientRow(ing)
                        }

                        if hiddenIngredientCount > 0 {
                            Text("+ ещё \(hiddenIngredientCount) \(ingredientWord(hiddenIngredientCount))")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 6)
                        }
                    }
                }
                .padding(14)
                .background(glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Полный состав (INCI)")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(product.full_composition)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )

                Text("purely · анализ состава косметики")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding(22)
            .frame(width: cardWidth, alignment: .top)
        }
        .frame(width: cardWidth)
    }

    private var ingredientsToShow: [Ingredient] {
        Array(product.ingredients.prefix(maxIngredientsOnCard))
    }

    private var hiddenIngredientCount: Int {
        max(0, product.ingredients.count - maxIngredientsOnCard)
    }

    private var ratingBlock: some View {
        HStack(spacing: 14) {
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
                .foregroundStyle(scoreColor(product.score))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(scoreColor(product.score).opacity(0.2))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
        .padding(14)
        .background(glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
    }

    private var glassBackground: Color {
        Color.white.opacity(0.16)
    }

    private func shareIngredientRow(_ ing: Ingredient) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Text(ing.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text(ing.riskLevel.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(ing.riskLevel.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ing.riskLevel.color.opacity(0.2))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }

            Text(ing.role)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))

            Text(ing.impact)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(4)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0...40:   return .red
        case 41...75:  return .orange
        default:       return .green
        }
    }

    private func ingredientWord(_ n: Int) -> String {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod100 >= 11, mod100 <= 14 { return "ингредиентов" }
        switch mod10 {
        case 1: return "ингредиент"
        case 2, 3, 4: return "ингредиента"
        default: return "ингредиентов"
        }
    }
}

// Рендер в UIImage

enum ProductShareImageGenerator {
    @MainActor
    static func makeImage(for product: Product) -> UIImage? {
        let view = ProductShareCardView(product: product)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = ProposedViewSize(width: 390, height: nil)
        return renderer.uiImage
    }
}


struct ShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareImagePayload: Identifiable {
    let id = UUID()
    let image: UIImage
}
