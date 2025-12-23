//
//  ItemView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 19.12.2025.
//

import SwiftUI

struct GlassButton: View {
    let title: String
    let score: Int

    private var scoreColor: Color {
        switch score {
        case 0...40:   return .red
        case 41...75:  return .orange
        default:       return .green
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Text("\(score)")
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .background(scoreColor.opacity(0.15))
                .foregroundStyle(scoreColor)
                .clipShape(Capsule())
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20)) // чтобы тапался весь прямоугольник
    }
}

#Preview {
    ZStack {
        Color(hex: "B55BE0").opacity(0.15).ignoresSafeArea()
        GlassButton(title: "Шампунь", score: 87)
            .padding()
    }
}
