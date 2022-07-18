//
//  AnimeViewCoordinator.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import UIKit
import Session

protocol AnimeViewCoordinatorProtocol: AnyObject {
    
}

final class AnimeViewCoordinator: Coordinator, AnimeViewCoordinatorProtocol {
    private let presenter: UINavigationController
    private var animeViewController: AnimeViewController?
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let interactor = AnimeViewInteractor(
            animeRepository: Session.shared,
            favoriteRepository: FavoriteAnimeRepository(storage: UserDefaults.standard)
        )
        let viewModel = AnimeViewModel(
            coordinator: self,
            interactor: interactor
        )
        let animeVC = AnimeViewController(viewModel: viewModel)
        animeViewController = animeVC
        presenter.pushViewController(animeVC, animated: true)
    }
}
