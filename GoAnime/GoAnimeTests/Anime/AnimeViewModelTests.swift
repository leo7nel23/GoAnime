//
//  AnimeViewModelTests.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
@testable import GoAnime
import XCTest

final class MockCoordinator: AnimeViewCoordinatorProtocol {
    
    var modelDidTap: ((AnimeItemModel) -> Void)?
    var routeSearch: ((AnimeItemType, FilterViewModelDelegate?) -> Void)?
    func anime(modelDidTap model: AnimeItemModel) {
        modelDidTap?(model)
    }
    
    func routeToSearch(animeType: AnimeItemType, delegate: FilterViewModelDelegate?) {
        routeSearch?(animeType, delegate)
    }
}

final class MockInteractor: AnimeViewInteractorProtocol {
    var reload: ((AnimeItemType) -> Void)?
    var loadMore: ((AnimeItemType) -> Void)?
    var addFavorite: ((AnimeItemModel) -> Void)?
    var removeFavorite: ((AnimeItemModel) -> Void)?
    
    @Published var animes: [AnimeItemModel] = []
    var animesPublished: Published<[AnimeItemModel]> { _animes}
    var animesPublisher: Published<[AnimeItemModel]>.Publisher { $animes}
    
    @Published var loadingState: LoadingState = .none
    var loadingStatePublished: Published<LoadingState> { _loadingState }
    var loadingStatePublisher: Published<LoadingState>.Publisher { $loadingState }
    
    func reload(type: AnimeItemType) {
        reload?(type)
    }
    
    func loadMore(type: AnimeItemType) {
        loadMore?(type)
    }
    
    func addFavorite(item: AnimeItemModel) {
        addFavorite?(item)
    }
    
    func removeFavorite(item: AnimeItemModel) {
        removeFavorite?(item)
    }
}

final class AnimeCoordinatorTests: XCTestCase {
    func test_Coordinator_action() {
        
        let coordinator = MockCoordinator()
        let favorite = FavoriteAnimeRepository(storage: MockItemStorage())
        let vm = AnimeViewModel(
            coordinator: coordinator,
            interactor: AnimeViewInteractor(
                animeRepository: MockAnimeRepository(),
                favoriteRepository: favorite
            )
        )
        
        let item = AnimeItemModel.mock
        _ = favorite.addFavorite(item: item)
        vm.segmentDidSelect(at: 2)
        vm.reloadData()
        
        let exp = expectation(description: #function)
        coordinator.routeSearch = { _, _ in
            exp.fulfill()
        }
        vm.searhDidTap()
        wait(for: [exp], timeout: 1.0)
        
        let exp2 = expectation(description: #function)
        coordinator.modelDidTap = { model in
            XCTAssertEqual(model.malId, 10)
            exp2.fulfill()
        }
        vm.userDidTap(at: IndexPath(item: 0, section: 0))
        wait(for: [exp2], timeout: 1.0)
    }
    
    func test_interactor_action() {
        let interactor = MockInteractor()
        let vm = AnimeViewModel(
            coordinator: MockCoordinator(),
            interactor: interactor
        )
        
        vm.segmentDidSelect(at: 2)
        
        let exp = expectation(description: #function)
        interactor.loadMore = {
            XCTAssertEqual($0, .favorite(.all))
            exp.fulfill()
        }
        vm.loadMore()
        wait(for: [exp], timeout: 1.0)
        
        let exp2 = expectation(description: #function)
        interactor.reload = {
            XCTAssertEqual($0, .favorite(.all))
            exp2.fulfill()
        }
        vm.reloadData()
        wait(for: [exp2], timeout: 1.0)
    }
    
    func test_segment_defaultType() {
        let interactor = MockInteractor()
        let vm = AnimeViewModel(
            coordinator: MockCoordinator(),
            interactor: interactor
        )
        
        var targetType: AnimeItemType = .manga(.all, .none)
        var exp = expectation(description: #function)
        
        interactor.reload = {
            XCTAssertEqual($0, targetType)
            exp.fulfill()
        }
        
        targetType = .manga(.all, .none)
        vm.segmentDidSelect(at: 0)
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: #function)
        targetType = .anime(.all, .none)
        vm.segmentDidSelect(at: 1)
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: #function)
        targetType = .favorite(.all)
        vm.segmentDidSelect(at: 2)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_interactor_favoriteItem() {
        let interactor = MockInteractor()
        let vm = AnimeViewModel(
            coordinator: MockCoordinator(),
            interactor: interactor
        )
        
        let item = AnimeItemModel.mock
        let cellConfig = AnimeItemConfiguration(model: item)
        
        var exp = expectation(description: #function)
        item.isFavorite = false
        interactor.addFavorite = {
            XCTAssertEqual($0.malId, item.malId)
            exp.fulfill()
        }
        vm.configuration(cellConfig, didTapFavorite: item)
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: #function)
        item.isFavorite = true
        interactor.removeFavorite = {
            XCTAssertEqual($0.malId, item.malId)
            exp.fulfill()
        }
        vm.configuration(cellConfig, didTapFavorite: item)
        wait(for: [exp], timeout: 1.0)
    }
}
