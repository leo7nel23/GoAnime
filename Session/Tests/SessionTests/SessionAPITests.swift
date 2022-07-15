//
//  SessionAPITests.swift
//  
//
//  Created by 賴柏宏 on 2022/7/15.
//

import XCTest
import Foundation
@testable import Session

class SessionAPITests: XCTestCase {
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    func test_TopManga_parameter() {
        var parameter = TopMangaParameter(page: 2, limit: 4, type: .all, filter: .bypopularity)
        
        XCTAssertTrue(parameter.path.contains("/top/manga"))
        XCTAssertTrue(parameter.path.contains("page=2"))
        XCTAssertTrue(parameter.path.contains("limit=4"))
        XCTAssertTrue(parameter.path.contains("filter=bypopularity"))
        XCTAssertFalse(parameter.path.contains("type"))
        
        parameter = TopMangaParameter(page: 1, limit: 6, type: .doujin, filter: .none)
        
        XCTAssertTrue(parameter.path.contains("/top/manga"))
        XCTAssertTrue(parameter.path.contains("page=1"))
        XCTAssertTrue(parameter.path.contains("limit=6"))
        XCTAssertTrue(parameter.path.contains("type=doujin"))
        XCTAssertFalse(parameter.path.contains("filter"))
    }
    
    func test_TopAnime_parameter() {
        var parameter = TopAnimeParameter(page: 2, limit: 4, type: .all, filter: .bypopularity)
        
        XCTAssertTrue(parameter.path.contains("/top/anime"))
        XCTAssertTrue(parameter.path.contains("page=2"))
        XCTAssertTrue(parameter.path.contains("limit=4"))
        XCTAssertTrue(parameter.path.contains("filter=bypopularity"))
        XCTAssertFalse(parameter.path.contains("type"))
        
        parameter = TopAnimeParameter(page: 1, limit: 6, type: .ova, filter: .none)
        
        XCTAssertTrue(parameter.path.contains("/top/anime"))
        XCTAssertTrue(parameter.path.contains("page=1"))
        XCTAssertTrue(parameter.path.contains("limit=6"))
        XCTAssertTrue(parameter.path.contains("type=ova"))
        XCTAssertFalse(parameter.path.contains("filter"))
    }
    
    func test_TopManga_Complete() async throws {
        let parameter = TopMangaParameter(
            page: 3,
            limit: 25,
            type: .lightnovel,
            filter: .bypopularity
        )
        
        MockAPI(
            parameter: parameter,
            data: AnimeResponse.topManga
        ).register()
        
        let result = try await Session
            .shared
            .request(parameter)
            .asyncSinked()
        
        let model = try XCTUnwrap(result)
        
        XCTAssertEqual(model.pagination.currentPage, 3)
        XCTAssertEqual(model.pagination.lastVisiblePage, 2564)
        XCTAssertTrue(model.pagination.hasNextPage)
        
        XCTAssertEqual(model.data.count, 2)
        
        let first = try XCTUnwrap(model.data.first)
        
        XCTAssertEqual(first.malId, 103851)
        XCTAssertEqual(first.url, "https://myanimelist.net/manga/103851/5-toubun_no_Hanayome")
        XCTAssertEqual(first.images.jpg.imageUrl, "https://cdn.myanimelist.net/images/manga/2/201572.jpg")
        XCTAssertEqual(first.images.jpg.smallImageUrl, "https://cdn.myanimelist.net/images/manga/2/201572t.jpg")
        XCTAssertEqual(first.images.jpg.largeImageUrl, "https://cdn.myanimelist.net/images/manga/2/201572l.jpg")
        XCTAssertEqual(first.title, "5-toubun no Hanayome")
        XCTAssertEqual(first.type, .manga)
        XCTAssertEqual(first.rank, 768)
        XCTAssertEqual(formatter.string(from: first.published.from), "2014-04-07")
        XCTAssertNil(first.published.to)
    }
    
    func test_TopAnime_Complete() async throws {
        let parameter = TopAnimeParameter(
            page: 3,
            limit: 2,
            type: .music,
            filter: .bypopularity
        )
        
        MockAPI(
            parameter: parameter,
            data: AnimeResponse.topAnime
        ).register()
        
        let result = try await Session
            .shared
            .request(parameter)
            .asyncSinked()
        
        let model = try XCTUnwrap(result)
        
        XCTAssertEqual(model.pagination.currentPage, 3)
        XCTAssertEqual(model.pagination.lastVisiblePage, 1099)
        XCTAssertTrue(model.pagination.hasNextPage)
        
        XCTAssertEqual(model.data.count, 2)
        
        let first = try XCTUnwrap(model.data.first)
        
        XCTAssertEqual(first.malId, 4705)
        XCTAssertEqual(first.url, "https://myanimelist.net/anime/4705/Tengen_Toppa_Gurren_Lagann__Parallel_Works")
        XCTAssertEqual(first.images.jpg.imageUrl, "https://cdn.myanimelist.net/images/anime/5/10986.jpg")
        XCTAssertEqual(first.images.jpg.smallImageUrl, "https://cdn.myanimelist.net/images/anime/5/10986t.jpg")
        XCTAssertEqual(first.images.jpg.largeImageUrl, "https://cdn.myanimelist.net/images/anime/5/10986l.jpg")
        XCTAssertEqual(first.title, "Tengen Toppa Gurren Lagann: Parallel Works")
        XCTAssertEqual(first.type, .music)
        XCTAssertEqual(first.rank, 3523)
        XCTAssertEqual(formatter.string(from: first.aired.from), "2008-06-15")
        
        let to = try XCTUnwrap(first.aired.to)
        XCTAssertEqual(formatter.string(from: to), "2008-09-14")
    }
    
    func test_AnimeType_parse() throws {
        struct Model: Codable {
            let type: AnimeType
        }
        
        var model = try JSONDecoder().decode(Model.self, from: ["type": "Music"].asData())
        XCTAssertEqual(model.type, .music)
        
        do {
            model = try JSONDecoder().decode(Model.self, from: ["type": "AAA"].asData())
        } catch {
            XCTAssertEqual(error as? SesssionError, .responseError(.parseJSONFail("")))
        }
    }
    
    func test_MangaType_parse() throws {
        struct Model: Codable {
            let type: MangaType
        }
        
        var model = try JSONDecoder().decode(Model.self, from: ["type": "Manga"].asData())
        XCTAssertEqual(model.type, .manga)
        
        do {
            model = try JSONDecoder().decode(Model.self, from: ["type": "AAA"].asData())
        } catch {
            XCTAssertEqual(error as? SesssionError, .responseError(.parseJSONFail("")))
        }
    }
}
