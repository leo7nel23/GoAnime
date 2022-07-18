//
//  AppCoordinator.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    
    private var window: UIWindow
    private let rootViewController: UINavigationController
    private let animeCoordinator: AnimeViewCoordinator
    
    init(window: UIWindow) {
        self.window = window
        window.tintColor = .systemTeal
        window.backgroundColor = .systemBackground
        
        rootViewController = UINavigationController()
        rootViewController.navigationBar.isTranslucent = false
        
        animeCoordinator = AnimeViewCoordinator(presenter: rootViewController)
    }
    
    func start() {
        window.rootViewController = rootViewController
        animeCoordinator.start()
        window.makeKeyAndVisible()
    }
}
