//
//  GradientBackgroundView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 21.11.2025.
//

import UIKit

class GradientBackgroundView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.67, green: 0.55, blue: 0.89, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.85, blue: 0.57, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 0.92, blue: 0.71, alpha: 1).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
