//
//  AnimeViewCoordinator.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import UIKit
import Session
import SafariServices

protocol AnimeViewCoordinatorProtocol: AnyObject {
    func anime(modelDidTap model: AnimeItemModel)
    func routeToSearch(animeType: AnimeItemType, delegate: FilterViewModelDelegate?)
}

final class AnimeViewCoordinator: Coordinator, AnimeViewCoordinatorProtocol {
    private let presenter: UINavigationController
    private let nextCoordinator: FilterCoordinator
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        self.nextCoordinator = FilterCoordinator(presenter: presenter)
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
        presenter.pushViewController(animeVC, animated: true)
    }
    
    func anime(modelDidTap model: AnimeItemModel) {
        guard let url = URL(string: model.url) else { return }
        let safari = SFSafariViewController(url: url)
        presenter.present(safari, animated: true)
    }
    
    func routeToSearch(
        animeType: AnimeItemType,
        delegate: FilterViewModelDelegate?
    ) {
        nextCoordinator.start(animeType: animeType, delegate: delegate)
    }
}
