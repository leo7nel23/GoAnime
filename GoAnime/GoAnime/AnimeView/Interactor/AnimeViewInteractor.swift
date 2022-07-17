//
//  AnimeViewInteractor.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import Session
import Combine
import TestHelper
import Utility

protocol AnimeViewInteractorProtocol {
    var animes: [AnimeItemModel] { get }
    var animesPublished: Published<[AnimeItemModel]> { get }
    var animesPublisher: Published<[AnimeItemModel]>.Publisher { get }
    
    var loadingState: LoadingState { get }
    var loadingStatePublished: Published<LoadingState> { get }
    var loadingStatePublisher: Published<LoadingState>.Publisher { get }
    
    func reload(type: AnimeItemType)
    func loadMore(type: AnimeItemType)
}

enum AnimeItemType: Codable {
    case anime(AnimeType, AnimeFilter)
    case manga(MangaType, AnimeFilter)
    case favorite(FavoriteType)
    
    enum FavoriteType {
        case anime(AnimeType, AnimeFilter)
        case manga(MangaType, AnimeFilter)
        case all
    }
}

enum LoadingState: Equatable {
    case none   // not loading
    case loading
    case error(Error)
    case finished   // No Next Page
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):        return true
        case (.loading, .loading):  return true
        case (.finished, .finished):return true
        case (.error, .error): return true
        default: return false
        }
    }
}

final class AnimeViewInteractor: AnimeViewInteractorProtocol {
    @Published var animes: [AnimeItemModel] = []
    var animesPublished: Published<[AnimeItemModel]> { _animes }
    var animesPublisher: Published<[AnimeItemModel]>.Publisher { $animes }
    
    @Published var loadingState: LoadingState = .none
    var loadingStatePublished: Published<LoadingState> { _loadingState }
    var loadingStatePublisher: Published<LoadingState>.Publisher { $loadingState }
    
    let animeRepository: AnimeRepositoryProtocol
    let favoriteRepository: FavoriteAnimeRepositoryProtocol
    
    private var cancellable: AnyCancellable?
    private let pageHandler: PageHandler = PageHandler()
    private var currentType: AnimeItemType = .manga(.all, .none)
    
    init(
        animeRepository: AnimeRepositoryProtocol,
        favoriteRepository: FavoriteAnimeRepositoryProtocol
    ) {
        self.animeRepository = animeRepository
        self.favoriteRepository = favoriteRepository
    }
    
    func reload(type: AnimeItemType) {
        cancellable = nil
        loadingState = .loading
        currentType = type
        if type.isFavorit {
            let info = AnimeItemInfoModel(currentPage: 1, hasNextPage: false, animeItems: favoriteRepository.favoriteItems())
            processAnime(info: info, type: type, isReload: true)
        } else {
            cancellable = animeRepository
                .topAnime(
                    type: type, page: 1, mockData: nil)
                .sink(receiveValue: { [weak self] info in
                    self?.processAnime(info: info, type: type, isReload: true)
                }, receiveFailure: { [weak self] error in
                    self?.loadingState = .error(error)
                })
        }
    }
    
    func loadMore(type: AnimeItemType) {
        guard !type.isFavorit else {
            animes = animes
            return
        }
        guard currentType == type else {
            reload(type: type)
            return
        }
        
        guard let page = nextPage(type: type) else {
            animes = animes
            return
        }
        
        cancellable = nil
        loadingState = .loading
        cancellable = animeRepository
            .topAnime(type: type, page: page, mockData: nil)
            .sink(receiveValue: { [weak self] info in
                self?.processAnime(info: info, type: type, isReload: false)
            }, receiveFailure: { [weak self] error in
                self?.loadingState = .error(error)
            })
    }
    
    private func nextPage(type: AnimeItemType) -> Int? {
        let page = pageHandler.currentPageInfo(for: type)
        
        guard page.hasNextPage else { return nil }
        return page.page + 1
    }
    
    private func processAnime(info: AnimeItemInfoModel, type: AnimeItemType, isReload: Bool) {
        loadingState = .none
        
        pageHandler
            .setPageInfo(
                page: info.currentPage,
                hasNextPage: info.hasNextPage,
                type: type
            )
        
        if isReload {
            animes = info.animeItems
        } else {
            animes.append(contentsOf: info.animeItems)
        }
        
        if !info.hasNextPage {
            loadingState = .finished
        }
    }
}

extension AnimeItemType {
    var isFavorit: Bool {
        switch self {
        case .favorite: return true
        default:        return false
        }
    }
}
