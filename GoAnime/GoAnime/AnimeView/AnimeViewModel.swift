//
//  AnimeViewModel.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation

protocol AnimeViewInteractorProtocol {
    
}

enum AnimeType {
    case manga
    case anime
    case favorite
    
    fileprivate var title: String {
        switch self {
        case .manga: return "Manga"
        case .anime: return "Anime"
        case .favorite: return "Favorite"
        }
    }
}

class AnimeViewModel {
    private weak var coordinator: AnimeViewCoordinatorProtocol?
    private var interactor: AnimeViewInteractorProtocol
    
    var segmentItems: [String] = {
        let animes: [AnimeType] = [.manga, .anime, .favorite]
        return animes.map { $0.title }
    }()
    
    var title: String = "Go Anime"
    
    @Published var segmentSelectedIndex: Int = 0
    
    init(
        coordinator: AnimeViewCoordinatorProtocol,
        interactor: AnimeViewInteractorProtocol
    ) {
        self.coordinator = coordinator
        self.interactor = interactor
    }
}
