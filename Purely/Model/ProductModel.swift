//
//  ProductModel.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 20.12.2025.
//


import SwiftUI
import Combine

struct Product: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let score: Int
    let description: String
    let ingredients: [Ingredient]
    let full_composition: String

    enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case score
        case description
        case ingredients
        case full_composition
    }

    init(name: String, score: Int, description: String = "", ingredients: [Ingredient], full_composition: String) {
        self.name = name
        self.score = score
        self.description = description
        self.ingredients = ingredients
        self.full_composition = full_composition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        if let intScore = try? container.decode(Int.self, forKey: .score) {
            score = intScore
        } else {
            let scoreString = try container.decode(String.self, forKey: .score)
            score = Int(scoreString) ?? 0
        }

        description = (try? container.decode(String.self, forKey: .description)) ?? ""
        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        full_composition = try container.decode(String.self, forKey: .full_composition)
    }
}

struct Ingredient: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    let role: String
    let impact: String
    let riskLevel: RiskLevel
    
    enum CodingKeys: String, CodingKey {
        case name
        case role = "function"
        case impact = "description"
        case riskLevel = "danger_level"
    }
    
    init(name: String, role: String, impact: String, riskLevel: RiskLevel) {
        self.name = name
        self.role = role
        self.impact = impact
        self.riskLevel = riskLevel
    }
}

final class ProductStore: ObservableObject {
    @Published var products: [Product]

    init(products: [Product] = Product.products) {
        self.products = products
    }
    
    func addProduct(_ product: Product) {
        products.append(product)
    }

    func removeProduct(_ product: Product) {
        products.removeAll { $0.id == product.id }
    }
}

enum RiskLevel: String, CaseIterable, Hashable, Codable {
    case low = "Низкий"
    case medium = "Средний"
    case high = "Высокий"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self))?.lowercased() ?? ""
        
        switch raw {
        case "low", "низкий":
            self = .low
        case "high", "высокий":
            self = .high
        default:
            self = .medium
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return Color(hex: "F2FF30")
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
    static var products: [Product] = [shampoo, serum, handCream] // Примеры для раздела "История"
    static let mock = shampoo
    
    static let shampoo = Product(
        name: "Шампунь для чувствительной кожи головы",
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
        full_composition: "Aqua, Sodium Laureth Sulfate, Cocamidopropyl Betaine, Panthenol, Parfum..."
    )
    
    static let serum = Product(
        name: "Сыворотка с ниацинамидом 10%",
        score: 92,
        ingredients: [
            Ingredient(
                name: "Niacinamide",
                role: "Антиоксидант / выравнивание тона",
                impact: "Улучшает барьер кожи, уменьшает воспаления и пигментацию.",
                riskLevel: .low
            ),
            Ingredient(
                name: "Hyaluronic Acid",
                role: "Увлажнение",
                impact: "Притягивает и удерживает влагу в роговом слое кожи.",
                riskLevel: .low
            )
        ],
        full_composition: "Aqua, Niacinamide, Glycerin, Sodium Hyaluronate, Panthenol, Phenoxyethanol..."
    )
    
    static let handCream = Product(
        name: "Крем для рук с маслом ши",
        score: 74,
        ingredients: [
            Ingredient(
                name: "Shea Butter",
                role: "Смягчение / питание",
                impact: "Смягчает кожу и уменьшает ощущение сухости и стянутости.",
                riskLevel: .low
            ),
            Ingredient(
                name: "Paraffinum Liquidum",
                role: "Окклюзив",
                impact: "Создаёт плёнку на поверхности кожи и уменьшает трансэпидермальную потерю влаги.",
                riskLevel: .medium
            )
        ],
        full_composition: "Aqua, Butyrospermum Parkii Butter, Paraffinum Liquidum, Glycerin, Cetearyl Alcohol, Parfum..."
    )
    
    static func addProduct(_ product: Product) {
        products.append(product)
    }

    /// Краткая характеристика рейтинга.
    var ratingSummary: String {
        switch score {
        case 0...40:   return "Сомнительный состав"
        case 41...75:  return "Неплохой состав"
        default:       return "Хороший состав"
        }
    }

}
