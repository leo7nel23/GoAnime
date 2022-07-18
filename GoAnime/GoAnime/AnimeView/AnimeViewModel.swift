//
//  AnimeViewModel.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import Combine
import UIKit

enum AnimeSegmentType: Int, CaseIterable {
    case manga = 0
    case anime = 1
    case favorite = 2
    
    fileprivate var title: String {
        switch self {
        case .manga: return "Manga"
        case .anime: return "Anime"
        case .favorite: return "Favorite"
        }
    }
}

enum LoadMoreState {
    case none
    case loading
    case finished
    case error(String)
}


final class AnimeViewModel {
    private weak var coordinator: AnimeViewCoordinatorProtocol?
    private var interactor: AnimeViewInteractorProtocol
    
    var segmentItems: [String] = AnimeSegmentType.allCases.map { $0.title }
    var title: String = "Go Anime"
    private var cancellable: Set<AnyCancellable> = []
    
    var segmentSelectedIndex: Int { segmentType.rawValue }
    private var segmentType: AnimeSegmentType = .manga
    private var animeItemType: AnimeItemType = .manga(.all, .none) {
        didSet {
            interactor.reload(type: animeItemType)
        }
    }
    
    var secionCount: Int = 1
    @Published private(set) var cellConfigurations: [AnimeItemConfiguration] = []
    @Published private(set) var loadMoreState: LoadMoreState = .none
    
    init(
        coordinator: AnimeViewCoordinatorProtocol,
        interactor: AnimeViewInteractorProtocol
    ) {
        self.coordinator = coordinator
        self.interactor = interactor
        bindPublisers()
        interactor.reload(type: animeItemType)
    }
    
    private func bindPublisers() {
        interactor
            .animesPublisher
            .sink { [weak self] models in
                self?.cellConfigurations = models.lazy.map { $0.cellConfiguration() }
            }
            .store(in: &cancellable)
        
        interactor
            .loadingStatePublisher
            .sink { [weak self] state in
                self?.secionCount = state == .finished ? 1 : 2
                
                self?.loadMoreState = {
                    switch state {
                    case .finished: return .finished
                    case .none:     return .none
                    case .loading:  return .loading
                    case .error(let error):    return .error("發生未知錯誤 \(error)")
                    }
                }()
            }
            .store(in: &cancellable)
    }
    
    func reloadData() {
        interactor.reload(type: animeItemType)
    }
    
    func loadMore() {
        interactor.loadMore(type: animeItemType)
    }
    
    func updateFilter(type: AnimeItemType) {
        animeItemType = type
    }
    
    func segmentDidSelect(at index: Int) {
        guard let segment = AnimeSegmentType(rawValue: index) else { return }
        segmentType = segment
        switch segment {
        case .manga:
            updateFilter(type: .manga(.all, .none))
        case .anime:
            updateFilter(type: .anime(.all, .none))
        case .favorite:
            updateFilter(type: .favorite(.all))
        }
    }
    
    func userDidTap(at indexPath: IndexPath) {
        guard indexPath.item < cellConfigurations.count else { return }
        let config = cellConfigurations[indexPath.item]
    }
}

extension AnimeItemModel {
    func cellConfiguration() -> AnimeItemConfiguration{
        AnimeItemConfiguration(model: self)
    }
}
