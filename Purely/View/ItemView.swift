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
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                
                Text("Косметический продукт")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer(minLength: 10)

            HStack(spacing: 6) {
                Text("\(score)")
                    .font(.title3.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(scoreColor.opacity(0.86))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    )
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.16))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    ZStack {
        AppScreenBackground()
        GlassButton(title: "Шампунь", score: 87)
            .padding()
    }
}
