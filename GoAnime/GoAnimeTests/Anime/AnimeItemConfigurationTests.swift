//
//  AnimeItemConfigurationTests.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import XCTest
@testable import GoAnime

final class AnimeItemConfigurationTests: XCTestCase {
    func test_configuration_data() {
        let item = AnimeItemModel.mock
        
        let config = AnimeItemConfiguration(model: item)
        XCTAssertEqual(config.id, item.id)
        XCTAssertEqual(config.imageUrl, item.imageUrl)
        XCTAssertEqual(config.title, item.title)
        XCTAssertEqual(config.type, item.type.rawValue)
        XCTAssertEqual(config.rank, String(item.rank ?? 0))
        XCTAssertEqual(config.fromDate, item.fromDate)
        XCTAssertEqual(config.toDate, item.toDate)
        XCTAssertEqual(config.isFavorite, item.isFavorite)
        
        XCTAssertEqual(config.dateText, "2022-07-18 ~ 2022-07-18")
        
        item.rank = nil
        XCTAssertEqual(config.rank, "-")
    }
    
    func test_configuraton_ViewType() {
        let config = AnimeItemConfiguration(model: .mock)
        XCTAssertTrue(config.makeContentView().isKind(of: AnimeItemContentView.self))
    }
    
    func test_tap_favorite() {
        let item = AnimeItemModel.mock
        
        let config = AnimeItemConfiguration(model: item)
        
        config.favoriteDidTapped()
        
        XCTAssertTrue(item.isFavorite)
    }
    
    func test_Nil_Date() {
        let item = AnimeItemModel.mock
        item.toDate = nil
        item.fromDate = nil
        let config = AnimeItemConfiguration(model: item)
        XCTAssertEqual(config.dateText, "- ~ -")
    }
}
