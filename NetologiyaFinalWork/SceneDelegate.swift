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
        let firstVC = MainScreenViewController()
        let firstNav = UINavigationController(rootViewController: firstVC)
        firstNav.tabBarItem = UITabBarItem(title: "Главная", 
                                           image: UIImage(systemName: "house"),
                                           tag: 0)
        
        // Второй экран: TasksTableViewController
        let tableVC1 = TasksTableViewController()
        let navTable1 = UINavigationController(rootViewController: tableVC1)
        navTable1.tabBarItem = UITabBarItem(title: "Задачи", 
                                            image: UIImage(systemName: "list.dash"),
                                            tag: 1)
        
        // Третий экран: SettingsTableViewController
        let tableVC2 = SettingsTableViewController()
        let navTable2 = UINavigationController(rootViewController: tableVC2)
        navTable2.tabBarItem = UITabBarItem(title: "Настройки", 
                                            image: UIImage(systemName: "gear"),
                                            tag: 2)
        
        // TabBarController
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [firstNav, navTable1, navTable2]
        
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

