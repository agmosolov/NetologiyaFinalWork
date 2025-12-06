//
//  SceneDelegate.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 01.12.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Первый экран: MainScreenViewController
        let mainScreenVC = MainScreenViewController()
        let mainScreenNav = UINavigationController(rootViewController: mainScreenVC)
        mainScreenNav.tabBarItem = UITabBarItem(title: "Главная", 
                                           image: UIImage(systemName: "house"),
                                           tag: 0)
        
        // Второй экран: TasksTableViewController
        let taskTVC = TasksTableViewController()
        let taskNav = UINavigationController(rootViewController: taskTVC)
        taskNav.tabBarItem = UITabBarItem(title: "Задачи", 
                                            image: UIImage(systemName: "target"),
                                            tag: 1)
        
        // Третий экран: TaskLogsTableViewController
        let logsTVC = TaskLogsTableViewController()
        let logsNav = UINavigationController(rootViewController: logsTVC)
        logsNav.tabBarItem = UITabBarItem(title: "Журнал", image: UIImage(systemName: "list.dash"), tag: 2)
        
        
        // Четвертый экран: SettingsTableViewController
        let settingsTVC = SettingsTableViewController()
        let settingsNav = UINavigationController(rootViewController: settingsTVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Настройки", 
                                            image: UIImage(systemName: "gear"),
                                            tag: 3)
        
        
        // TabBarController
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [mainScreenNav, taskNav, logsNav, settingsNav]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
    
}

