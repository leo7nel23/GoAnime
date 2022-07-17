//
//  FavoriteItemTests.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
import XCTest
@testable import GoAnime

final class MockItemStorage: ItemStorageProtocol {
    var storage: [String: Data] = [:]
    
    func set(item: Data, for key: String) { storage[key] = item }
    func getItem(for key: String) -> Data? { storage[key] }
    func getItem<T>(for key: String, _ mapper: ((Data) -> T?)) -> T? {
        guard let data = getItem(for: key) else { return nil }
        return mapper(data)
    }
}

final class FavoriteAnimeRepositoryTests: XCTestCase {
    func test_request_Favorite() async throws {
        let model = AnimeItemModel(
            malId: 10,
            url: "url",
            imageUrl: "imageUrl",
            thumbnailUrl: "thumbnailUrl",
            title: "title",
            rank: 10,
            type: .anime(.music, .airing),
            fromDate: Date(),
            toDate: Date().addingTimeInterval(100)
        )
        let repository = FavoriteAnimeRepository(storage: MockItemStorage())
        var items = repository.favoriteItems()
        
        XCTAssertEqual(items.count, 0)
        
        _ = repository.addFavorite(item: model)
        items = repository.favoriteItems()
        XCTAssertEqual(items.count, 1)
        let item = try XCTUnwrap(items.first)
        
        XCTAssertEqual(item.malId, 10)
        XCTAssertEqual(item.url, "url")
        XCTAssertEqual(item.imageUrl, "imageUrl")
        XCTAssertEqual(item.thumbnailUrl, "thumbnailUrl")
        XCTAssertEqual(item.title, "title")
        XCTAssertEqual(item.rank, 10)
        XCTAssertEqual(item.type, .anime(.music, .airing))
        XCTAssertEqual(item.isFavorite, true)
        
        let removed = repository.removeFavorite(item: model)
        items = repository.favoriteItems()
        XCTAssertEqual(items.count, 0)
        
        XCTAssertFalse(removed.isFavorite)
    }
}
