//
//  HistoryItemView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 21.11.2025.
//

import UIKit

final class HistoryCell: UITableViewCell {

    private let container: UIView = { // ячейка товара
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 30
        v.layer.masksToBounds = true
        return v
    }()

    private let titleLabel: UILabel = { // название товара
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .medium)
        label.textColor = .black
        return label
    }()

    private let scoreView = UIView() 
    private let scoreLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        scoreView.layer.cornerRadius = 35
        scoreLabel.font = .systemFont(ofSize: 28, weight: .bold)
        scoreLabel.textColor = .black

        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        contentView.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(scoreView)
        scoreView.addSubview(scoreLabel)

        container.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            scoreView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            scoreView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            scoreView.widthAnchor.constraint(equalToConstant: 70),
            scoreView.heightAnchor.constraint(equalToConstant: 70),

            scoreLabel.centerXAnchor.constraint(equalTo: scoreView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreView.centerYAnchor)
        ])
    }

    func configure(name: String, score: Int) {
        titleLabel.text = name
        scoreLabel.text = "\(score)"

        switch score {
        case 80...100: scoreView.backgroundColor = UIColor.systemGreen
        case 60..<80:  scoreView.backgroundColor = UIColor.yellow
        case 40..<60:  scoreView.backgroundColor = UIColor.orange
        default:       scoreView.backgroundColor = UIColor.systemRed
        }
    }
}
