import UIKit


// Сканирование товара
final class ScanViewController: UIViewController {


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сканировать"
        label.font = .systemFont(ofSize: 38, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Заглушка
    private let cameraPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.layer.cornerRadius = 48
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Сделать снимок"
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule
        config.titleAlignment = .center
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 32, bottom: 14, trailing: 32)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 20, weight: .semibold)
            return outgoing
        }
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let flashButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "bolt.fill", withConfiguration: config), for: .normal)
        button.tintColor = UIColor.systemYellow
        button.backgroundColor = .white
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func loadView() {
        // общий градиент для этого экрана
        view = GradientBackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        layoutUI()
    }

    private func layoutUI() {
        view.addSubview(titleLabel)
        view.addSubview(cameraPlaceholderView)
        view.addSubview(shutterButton)
        view.addSubview(flashButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cameraPlaceholderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            cameraPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            cameraPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            cameraPlaceholderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55),

            shutterButton.topAnchor.constraint(equalTo: cameraPlaceholderView.bottomAnchor, constant: 40),
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.heightAnchor.constraint(equalToConstant: 64),
            shutterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),

            flashButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
            flashButton.leadingAnchor.constraint(equalTo: shutterButton.trailingAnchor, constant: 16),
            flashButton.widthAnchor.constraint(equalToConstant: 64),
            flashButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
}
