//
//  AppCoordinator.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    
    private var window: UIWindow
    private let rootViewController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        window.tintColor = .systemPink
        window.backgroundColor = .systemBackground
        
        rootViewController = UINavigationController()
        rootViewController.navigationBar.isTranslucent = false
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
