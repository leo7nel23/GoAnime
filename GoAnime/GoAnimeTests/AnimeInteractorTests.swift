//
//  AnimeInteractorTests.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
import XCTest
@testable import GoAnime
import Session
import TestHelper
import Combine

final class AnimeInteractorTests: XCTestCase {
    final class MockAnimeRepository: AnimeRepositoryProtocol {
        var response: AnimeItemInfoModel = AnimeItemInfoModel(currentPage: 0, hasNextPage: true, animeItems: [])
        var error: Error?
        func topAnime(type: AnimeItemType, page: Int, mockData: DataConvertible?) -> AnyPublisher<AnimeItemInfoModel, Error> {
            if let error = error {
                return Fail(error: error).eraseToAnyPublisher()
            }
            return CurrentValueSubject<AnimeItemInfoModel, Error>(response).eraseToAnyPublisher()
        }
    }
    var cancellable: Set<AnyCancellable> = []
    
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    func test_loadUntilFiished() throws {
        var targetCount: Int = 0
        let animeRepository = MockAnimeRepository()
        let interactor = AnimeViewInteractor(
            animeRepository: animeRepository,
            favoriteRepository: FavoriteAnimeRepository(storage: MockItemStorage())
        )
        let type: AnimeItemType = .anime(.all, .none)
        
        var exp = expectation(description: #function)
        
        interactor
            .animesPublisher
            .dropFirst()
            .sink { models in
                XCTAssertEqual(models.count, targetCount)
                exp.fulfill()
            }
            .store(in: &cancellable)
        
        let targetState: [LoadingState] = [.loading, .none, .loading, .none, .loading, .none, .finished]
        var index: Int = 0
        interactor
            .loadingStatePublisher
            .dropFirst()
            .sink { state in
                XCTAssertEqual(state, targetState[index])
                index += 1
            }
            .store(in: &cancellable)
        
        animeRepository.response = try decoder
            .decode(TopAnimeModel.self, from: Helper.topAnime.asData())
            .asAnimeItemInfo(filter: .none)
        targetCount = 2
        interactor.reload(type: type)
        
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: #function)
        animeRepository.response = try decoder
            .decode(TopAnimeModel.self, from: Helper.topAnime.asData())
            .asAnimeItemInfo(filter: .none)
        targetCount = 4
        interactor.loadMore(type: type)
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: #function)
        animeRepository.response = try decoder
            .decode(TopAnimeModel.self, from: Helper.topAnimeEnd.asData())
            .asAnimeItemInfo(filter: .none)
        targetCount = 6
        interactor.loadMore(type: type)
        wait(for: [exp], timeout: 1.0)
        
        // data finished, no load anymore
        exp = expectation(description: #function)
        animeRepository.response = try decoder
            .decode(TopAnimeModel.self, from: Helper.topAnimeEnd.asData())
            .asAnimeItemInfo(filter: .none)
        targetCount = 6
        interactor.loadMore(type: type)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(index, 7)
    }
    
    func test_loadMore_IncorrectType() throws {
        var targetCount: Int = 0
        let animeRepository = MockAnimeRepository()
        let interactor = AnimeViewInteractor(
            animeRepository: animeRepository,
            favoriteRepository: FavoriteAnimeRepository(storage: MockItemStorage())
        )
        
        var exp = expectation(description: #function)
        
        interactor
            .animesPublisher
            .dropFirst()
            .sink { models in
                XCTAssertEqual(models.count, targetCount)
                exp.fulfill()
            }
            .store(in: &cancellable)
        
        animeRepository.response = try decoder
            .decode(TopMangaModel.self, from: Helper.topManga.asData())
            .asAnimeItemInfo(filter: .none)
        targetCount = 2
        interactor.reload(type: .manga(.all, .none))
        
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: #function)
        animeRepository.response = try decoder
            .decode(TopAnimeModel.self, from: Helper.topAnime.asData())
            .asAnimeItemInfo(filter: .none)
        targetCount = 2
        interactor.loadMore(type: .anime(.all, .none))
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFavorite_UntilFiished() throws {
        var targetCount: Int = 0
        let favoriteRepository = FavoriteAnimeRepository(storage: MockItemStorage())
        let interactor = AnimeViewInteractor(
            animeRepository: MockAnimeRepository(),
            favoriteRepository: favoriteRepository
        )
        
        let item = AnimeItemModel(
            malId: 10,
            url: "url",
            imageUrl: "imageUrl",
            thumbnailUrl: "thumbnailUrl",
            title: "title",
            rank: 100,
            type: .manga(.all, .none),
            fromDate: Date(),
            toDate: Date()
        )
        
        _ = favoriteRepository.addFavorite(item: item)
        
        let type: AnimeItemType = .favorite(.all)
        
        var exp = expectation(description: #function)
        
        interactor
            .animesPublisher
            .dropFirst()
            .sink { models in
                XCTAssertEqual(models.count, targetCount)
                exp.fulfill()
            }
            .store(in: &cancellable)
        
        targetCount = 1
        interactor.reload(type: type)
        
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: #function)
        targetCount = 1
        interactor.loadMore(type: type)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_reload_withError() {
        let animeRepository = MockAnimeRepository()
        let interactor = AnimeViewInteractor(
            animeRepository: animeRepository,
            favoriteRepository: FavoriteAnimeRepository(storage: MockItemStorage())
        )
        let type: AnimeItemType = .anime(.all, .none)
        let error = SesssionError.responseError(.badServerResponse(503))
        let exp = expectation(description: #function)
        
        interactor
            .loadingStatePublisher
            .dropFirst(2)
            .sink(receiveValue: { state in
                XCTAssertEqual(state, .error(error))
                if case let .error(error) = state,
                   let sError = error as? SesssionError {
                    XCTAssertEqual(sError, SesssionError.responseError(.badServerResponse(503)))
                } else {
                    XCTFail()
                }
                exp.fulfill()
            })
            .store(in: &cancellable)
        animeRepository.error = error
        interactor.reload(type: type)
        
        wait(for: [exp], timeout: 10.0)
    }
    
    func test_PageHandler() {
        let pageHandler = PageHandler()
        let page1 = pageHandler.currentPageInfo(for: .favorite(.all))
        XCTAssertEqual(page1.page, 0)
        XCTAssertEqual(page1.hasNextPage, true)
        
        let type: AnimeItemType = .anime(.all, .none)
        pageHandler.setPageInfo(page: 10, hasNextPage: true, type: type)
        let page2 = pageHandler.currentPageInfo(for: type)
        
        XCTAssertEqual(page2.page, 10)
        XCTAssertEqual(page2.hasNextPage, true)
    }
}
