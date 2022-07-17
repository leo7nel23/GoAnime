//
//  SessionInteractorTests.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
@testable import GoAnime
import Session
import XCTest
import TestHelper

final class SessionInteractorTests: XCTestCase {
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    func test_request_Anime() async throws {
        let repository: AnimeRepositoryProtocol = Session.shared
        
        let model = try await repository
            .topAnime(type: .anime(.all, .none), page: 1, mockData: Helper.topAnime)
            .asyncSinked()
        
        XCTAssertEqual(model?.currentPage, 3)
        XCTAssertEqual(model?.hasNextPage, true)
        XCTAssertEqual(model?.animeItems.count, 2)
        
        let item = model?.animeItems.first
        
        XCTAssertEqual(item?.malId, 4705)
        XCTAssertEqual(item?.url, "https://myanimelist.net/anime/4705/Tengen_Toppa_Gurren_Lagann__Parallel_Works")
        XCTAssertEqual(item?.imageUrl, "https://cdn.myanimelist.net/images/anime/5/10986.jpg")
        XCTAssertEqual(item?.thumbnailUrl, "https://cdn.myanimelist.net/images/anime/5/10986t.jpg")
        XCTAssertEqual(item?.title, "Tengen Toppa Gurren Lagann: Parallel Works")
        XCTAssertEqual(item?.rank, 3523)
        XCTAssertEqual(item?.type, .anime(.music, .none))
        XCTAssertEqual(formatter.string(from: item?.fromDate ?? Date()), "2008-06-15")
        XCTAssertEqual(formatter.string(from: item?.toDate ?? Date()), "2008-09-14")
    }
    
    func test_request_Manga() async throws {
        let repository: AnimeRepositoryProtocol = Session.shared
        
        let model = try await repository
            .topAnime(type: .manga(.lightnovel, .airing), page: 1, mockData: Helper.topManga)
            .asyncSinked()
        
        XCTAssertEqual(model?.currentPage, 3)
        XCTAssertEqual(model?.hasNextPage, true)
        XCTAssertEqual(model?.animeItems.count, 2)
        
        let item = model?.animeItems.first
        
        XCTAssertEqual(item?.malId, 103851)
        XCTAssertEqual(item?.url, "https://myanimelist.net/manga/103851/5-toubun_no_Hanayome")
        XCTAssertEqual(item?.imageUrl, "https://cdn.myanimelist.net/images/manga/2/201572.jpg")
        XCTAssertEqual(item?.thumbnailUrl, "https://cdn.myanimelist.net/images/manga/2/201572t.jpg")
        XCTAssertEqual(item?.title, "5-toubun no Hanayome")
        XCTAssertEqual(item?.rank, 768)
        XCTAssertEqual(item?.type, .manga(.manga, .airing))
        XCTAssertEqual(formatter.string(from: item?.fromDate ?? Date()), "2014-04-07")
        XCTAssertEqual(formatter.string(from: item?.toDate ?? Date()), "2022-07-17")
    }
}
