//
//  SceneDelegate.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 01.12.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var tabBarController: UITabBarController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let loginVC = LoginViewController()
        loginVC.title = "Вход"
        let loginNav = UINavigationController(rootViewController: loginVC)

        let mainScreenVC = MainScreenViewController()
        let taskTVC = TasksTableViewController()
        let logsTVC = TaskLogsTableViewController()
        let settingsTVC = SettingsTableViewController()

        let mainNav = UINavigationController(rootViewController: mainScreenVC)
        let taskNav = UINavigationController(rootViewController: taskTVC)
        let logsNav = UINavigationController(rootViewController: logsTVC)
        let settingsNav = UINavigationController(rootViewController: settingsTVC)

        mainNav.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), tag: 0)
        taskNav.tabBarItem = UITabBarItem(title: "Задачи", image: UIImage(systemName: "flag"), tag: 1)
        logsNav.tabBarItem = UITabBarItem(title: "Журнал", image: UIImage(systemName: "list.dash"), tag: 2)
        settingsNav.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 3)

        tabBarController = UITabBarController()
        tabBarController?.viewControllers = [mainNav, taskNav, logsNav, settingsNav]

        window?.rootViewController = loginNav
        window?.makeKeyAndVisible()

        NotificationCenter.default.addObserver(self, selector: #selector(loginDidSucceed), name: NSNotification.Name("LoginDidSucceed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registrationDidSucceed), name: NSNotification.Name("RegistrationDidSucceed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: NSNotification.Name("LogoutRequested"), object: nil)
    }

    
    @objc private func loginDidSucceed() {
        if let tabBarController = tabBarController {
            window?.rootViewController = tabBarController
        } else {
            let mainScreenVC = MainScreenViewController()
            let taskTVC = TasksTableViewController()
            let logsTVC = TaskLogsTableViewController()
            let settingsTVC = SettingsTableViewController()

            let mainNav = UINavigationController(rootViewController: mainScreenVC)
            let taskNav = UINavigationController(rootViewController: taskTVC)
            let logsNav = UINavigationController(rootViewController: logsTVC)
            let settingsNav = UINavigationController(rootViewController: settingsTVC)

            mainNav.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), tag: 0)
            taskNav.tabBarItem = UITabBarItem(title: "Задачи", image: UIImage(systemName: "flag"), tag: 1)
            logsNav.tabBarItem = UITabBarItem(title: "Журнал", image: UIImage(systemName: "list.dash"), tag: 2)
            settingsNav.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 3)

            let tb = UITabBarController()
            tb.viewControllers = [mainNav, taskNav, logsNav, settingsNav]
            self.tabBarController = tb
            window?.rootViewController = tb
        }
        window?.makeKeyAndVisible()
    }

    
    @objc private func registrationDidSucceed() {
        loginDidSucceed()
    }
    
    
    @objc private func logoutRequested() {
        let loginVC = LoginViewController()
        let loginNav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = loginNav
        window?.makeKeyAndVisible()
    }
    
    
    @objc private func handleLogout() {
           let loginVC = LoginViewController()
           let loginNav = UINavigationController(rootViewController: loginVC)
           window?.rootViewController = loginNav
           window?.makeKeyAndVisible()
       }

    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LoginDidSucceed"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("RegistrationDidSucceed"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LogoutRequested"), object: nil)
    }
}

