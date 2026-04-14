//
//  RootTabBarController.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 21.11.2025.
//


// Таббар
import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let historyVC = HistoryViewController()
        let scanVC    = ScanViewController()

        historyVC.tabBarItem = UITabBarItem(
            title: "История",
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock.fill")
        )

        scanVC.tabBarItem = UITabBarItem(
            title: "Сканировать",
            image: UIImage(systemName: "camera"),
            selectedImage: UIImage(systemName: "camera.fill")
        )

        viewControllers = [
            UINavigationController(rootViewController: historyVC),
            UINavigationController(rootViewController: scanVC)
        ]

        setupTabBarAppearance()
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance

        tabBar.tintColor = UIColor.black
        tabBar.unselectedItemTintColor = UIColor(white: 1.0, alpha: 0.6)

        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear
    }
}
