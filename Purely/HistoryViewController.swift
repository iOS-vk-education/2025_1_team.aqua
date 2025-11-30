import UIKit

final class HistoryViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "История"
        label.font = .systemFont(ofSize: 44, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()


    private let items: [(name: String, score: Int)] = [
        ("Гель для душа", 92),
        ("Шампунь", 92),
        ("Кондиционер", 64),
        ("Гель для умывания", 75),
        ("Зубная паста", 80),
        ("Крем для рук", 25)
    ]

    override func loadView() {
        // общий градиент для этого экрана
        view = GradientBackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        setupTable()
        layoutUI()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")

        // чтобы последний айтем не прятался за таб-баром
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
    }

    private func layoutUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension HistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryCell",
            for: indexPath
        ) as? HistoryCell else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]
        cell.configure(name: item.name, score: item.score)
        return cell
    }
}


extension HistoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
