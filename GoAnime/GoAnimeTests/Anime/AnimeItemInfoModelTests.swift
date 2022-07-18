//
//  AnimeItemInfoModelTests.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
import XCTest
import Session
@testable import GoAnime

final class AnimeItemInfoModelTests: XCTestCase {
    func test_AnimeItemType_Encode() throws {
        struct MockType: Codable {
            var type: AnimeItemType
            init(type: AnimeItemType) {
                self.type = type
            }
        }
        
        func jsonText(_ type: AnimeItemType) -> String {
            return "{\"type\":\"\(type.rawValue)\"}"
        }
        
        let encoder = JSONEncoder()
        
        let types: [AnimeItemType] = [
            .manga(.manga, .airing),
            .anime(.ona, .bypopularity),
            .favorite(.anime(.music, .upcoming)),
            .favorite(.manga(.doujin, .favorite)),
            .favorite(.all)
        ]
        
        try types.forEach {
            let mock = MockType(type: $0)
            let data = try encoder.encode(mock)
            let string = String(data: data, encoding: .utf8)
            
            XCTAssertEqual(string, jsonText($0))
        }
    }
    
    func test_AnimeItemType_Decode() {
        XCTAssertEqual(AnimeItemType(rawValue: "Favorite_Manga_Anime"), .favorite(.all))
        XCTAssertEqual(AnimeItemType(rawValue: "Favorite_doujin_upcoming"), .favorite(.manga(.doujin, .upcoming)))
        XCTAssertEqual(AnimeItemType(rawValue: "Favorite_ona_favorite"), .favorite(.anime(.ona, .favorite)))
        XCTAssertEqual(AnimeItemType(rawValue: "Anime_music_bypopularity"), .anime(.music, .bypopularity))
        XCTAssertEqual(AnimeItemType(rawValue: "Manga_lightnovel_airing"), .manga(.lightnovel, .airing))
        
        XCTAssertNil(AnimeItemType(rawValue: ""))
        XCTAssertNil(AnimeItemType(rawValue: "Anime_music_bypopularit"))
        XCTAssertNil(AnimeItemType(rawValue: "Manga_lightnvel_airing"))
        XCTAssertNil(AnimeItemType(rawValue: "Favorte_ona_favorite"))
        XCTAssertNil(AnimeItemType(rawValue: "Favorite_ona_favorte"))
    }
    
    func test_TopAnimeModel_to_InfoModel() throws {
        let page = Pagination(
            lastVisiblePage: 10,
            hasNextPage: true,
            currentPage: 9
        )
        let now = Date()
        let to = now.addingTimeInterval(100)
        
        let animeItem = AnimeItem(
            malId: 10,
            url: "url",
            images: AnimeItem.Images(
                jpg: AnimeItem.Images.ImagesItem(
                    imageUrl: "imageUrl",
                    smallImageUrl: "smallImageUrl",
                    largeImageUrl: "largeImageUrl"
                )
            ),
            title: "title",
            rank: 10,
            type: .music,
            aired: AnimeItem.Aired(
                from: now,
                to: to
            )
        )
        
        let anime = TopAnimeModel(pagination: page, data: [animeItem])
        let info = anime.asAnimeItemInfo(filter: .airing)
        
        XCTAssertEqual(info.currentPage, 9)
        XCTAssertEqual(info.hasNextPage, true)
        XCTAssertEqual(info.animeItems.count, 1)
    
        let item = try XCTUnwrap(info.animeItems.first)
        
        XCTAssertEqual(item.malId, 10)
        XCTAssertEqual(item.url, "url")
        XCTAssertEqual(item.imageUrl, "imageUrl")
        XCTAssertEqual(item.thumbnailUrl, "smallImageUrl")
        XCTAssertEqual(item.title, "title")
        XCTAssertEqual(item.rank, 10)
        XCTAssertEqual(item.type, .anime(.music, .airing))
        XCTAssertEqual(item.fromDate, now)
        XCTAssertEqual(item.toDate, to)
    }
    
    func test_TopMangaModel_to_InfoModel() throws {
        let page = Pagination(
            lastVisiblePage: 10,
            hasNextPage: true,
            currentPage: 9
        )
        let now = Date()
        let to = now.addingTimeInterval(100)
        
        let mangaItem = MangaItem(
            malId: 10,
            url: "url",
            images: MangaItem.Images(
                jpg: MangaItem.Images.ImagesItem(
                    imageUrl: "imageUrl",
                    smallImageUrl: "smallImageUrl",
                    largeImageUrl: "largeImageUrl"
                )
            ),
            title: "title",
            rank: 10,
            type: .lightnovel,
            published: MangaItem.Published(
                from: now,
                to: to
            )
        )
        
        let manga = TopMangaModel(pagination: page, data: [mangaItem])
        let info = manga.asAnimeItemInfo(filter: .bypopularity)
        
        XCTAssertEqual(info.currentPage, 9)
        XCTAssertEqual(info.hasNextPage, true)
        XCTAssertEqual(info.animeItems.count, 1)
    
        let item = try XCTUnwrap(info.animeItems.first)
        
        XCTAssertEqual(item.malId, 10)
        XCTAssertEqual(item.url, "url")
        XCTAssertEqual(item.imageUrl, "imageUrl")
        XCTAssertEqual(item.thumbnailUrl, "smallImageUrl")
        XCTAssertEqual(item.title, "title")
        XCTAssertEqual(item.rank, 10)
        XCTAssertEqual(item.type, .manga(.lightnovel, .bypopularity))
        XCTAssertEqual(item.fromDate, now)
        XCTAssertEqual(item.toDate, to)
    }
}
