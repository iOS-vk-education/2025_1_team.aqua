//
//  ProductModel.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 20.12.2025.
//


import SwiftUI

struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let score: Int
    let ingredients: [Ingredient]
    let fullINCI: String
}

struct Ingredient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let role: String
    let impact: String
    let riskLevel: RiskLevel
}

enum RiskLevel: String, CaseIterable, Hashable {
    case low = "Низкий"
    case medium = "Средний"
    case high = "Высокий"

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// Hex helper (для фона B55BE0)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}


extension Product {
    static let mock = Product(
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
    )
}
