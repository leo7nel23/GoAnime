//
//  FilterViewModelTests.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import XCTest
@testable import GoAnime
import Session

class MockFilterViewModelDelegate: FilterViewModelDelegate {
    var checked: ((AnimeItemType) -> Void)?
    func viewModel(_ model: FilterViewModel, didCheckd type: AnimeItemType) {
        checked?(type)
    }
}

final class FilterViewModelTests: XCTestCase {
    func test_type_detail() {
        let animeDetail = AnimeType.types()
        XCTAssertFalse(animeDetail.contains("all"))
        XCTAssertEqual(animeDetail.count, 6)
        
        let mangaDetail = MangaType.types()
        XCTAssertFalse(mangaDetail.contains("all"))
        XCTAssertEqual(mangaDetail.count, 7)
        
        let animeFilter = AnimeFilter.types()
        XCTAssertFalse(animeFilter.contains("none"))
        XCTAssertEqual(animeFilter.count, 4)
    }
    
    func test_initFilterType() {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .anime(.music, .airing)
        )
        
        let delegate = MockFilterViewModelDelegate()
        vm.deleage = delegate
        
        let exp = expectation(description: #function)
        delegate.checked = {
            XCTAssertEqual($0, .anime(.music, .airing))
            exp.fulfill()
        }
        vm.animeTypeChecked()
        wait(for: [exp], timeout: 1.0)
        
        let exp2 = expectation(description: #function)
        let vm2 = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .manga(.doujin, .bypopularity)
        )
        vm2.deleage = delegate
        delegate.checked = {
            XCTAssertEqual($0, .manga(.doujin, .bypopularity))
            exp2.fulfill()
        }
        
        vm2.animeTypeChecked()
        wait(for: [exp2], timeout: 1.0)
        
        let exp3 = expectation(description: #function)
        let vm3 = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .favorite(.all)
        )
        vm3.deleage = delegate
        delegate.checked = {
            XCTAssertEqual($0, .favorite(.all))
            exp3.fulfill()
        }
        vm3.animeTypeChecked()
        wait(for: [exp3], timeout: 1.0)
    }
    
    func test_contentModel_anime() throws {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .anime(.music, .airing)
        )
        
        let delegate = MockFilterViewModelDelegate()
        vm.deleage = delegate
        
        let typeModel = try XCTUnwrap(vm.typeModel)
        XCTAssertEqual(typeModel.type, .type)
        XCTAssertEqual(typeModel.detail.count, 6)
        
        let filterModel = try XCTUnwrap(vm.filterModel)
        
        XCTAssertEqual(filterModel.type, .filter)
        XCTAssertEqual(filterModel.detail.count, 4)
    }
    
    func test_contentModel_manga() throws {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .manga(.lightnovel, .airing)
        )
        
        let delegate = MockFilterViewModelDelegate()
        vm.deleage = delegate
        
        let typeModel = try XCTUnwrap(vm.typeModel)
        XCTAssertEqual(typeModel.type, .type)
        XCTAssertEqual(typeModel.detail.count, 7)
        
        let filterModel = try XCTUnwrap(vm.filterModel)
        
        XCTAssertEqual(filterModel.type, .filter)
        XCTAssertEqual(filterModel.detail.count, 4)
    }
    
    func test_contentModel_favorite() throws {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .favorite(.all)
        )
        
        let delegate = MockFilterViewModelDelegate()
        vm.deleage = delegate
        
        XCTAssertNil(vm.typeModel)
        XCTAssertNil(vm.filterModel)
    }
    
    func test_selected_item_anime() {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .anime(.music, .airing)
        )
        
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.airing.rawValue)
        XCTAssertEqual(vm.selectedItem(type: .type), AnimeType.music.rawValue)
    }
    
    func test_selected_item_manga() {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .manga(.lightnovel, .airing)
        )
        
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.airing.rawValue)
        XCTAssertEqual(vm.selectedItem(type: .type), MangaType.lightnovel.rawValue)
    }
    
    func test_selected_item_favorite() {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .favorite(.all)
        )
        
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.none.rawValue)
        XCTAssertEqual(vm.selectedItem(type: .type), "")
    }
    
    func test_setSelected_anime() {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .anime(.music, .airing)
        )
        
        vm.setSelected(type: .filter, item: "favorite")
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.favorite.rawValue)
        vm.setSelected(type: .filter, item: "ssss")
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.none.rawValue)
        vm.setSelected(type: .filter, item: nil)
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.none.rawValue)
        
        vm.setSelected(type: .type, item: "music")
        XCTAssertEqual(vm.selectedItem(type: .type), AnimeType.music.rawValue)
        vm.setSelected(type: .type, item: "sss")
        XCTAssertEqual(vm.selectedItem(type: .type), AnimeType.all.rawValue)
        vm.setSelected(type: .type, item: nil)
        XCTAssertEqual(vm.selectedItem(type: .type), AnimeType.all.rawValue)
    }
    
    func test_setSelected_manga() {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .manga(.lightnovel, .airing)
        )
        
        vm.setSelected(type: .filter, item: "airing")
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.airing.rawValue)
        vm.setSelected(type: .filter, item: "sss")
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.none.rawValue)
        vm.setSelected(type: .filter, item: nil)
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.none.rawValue)
        
        vm.setSelected(type: .type, item: "doujin")
        XCTAssertEqual(vm.selectedItem(type: .type), MangaType.doujin.rawValue)
        vm.setSelected(type: .type, item: "aaa")
        XCTAssertEqual(vm.selectedItem(type: .type), MangaType.all.rawValue)
        vm.setSelected(type: .type, item: nil)
        XCTAssertEqual(vm.selectedItem(type: .type), MangaType.all.rawValue)
    }
    
    func test_setSelected_favorite() {
        let vm = FilterViewModel(
            coordinator: FilterCoordinator(presenter: UINavigationController()),
            animeType: .favorite(.all)
        )
        
        vm.setSelected(type: .filter, item: "bypopularity")
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.bypopularity.rawValue)
        vm.setSelected(type: .filter, item: "sss")
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.none.rawValue)
        vm.setSelected(type: .filter, item: nil)
        XCTAssertEqual(vm.selectedItem(type: .filter), AnimeFilter.none.rawValue)
        
        vm.setSelected(type: .type, item: "doujin")
        XCTAssertEqual(vm.selectedItem(type: .type), "")
        vm.setSelected(type: .type, item: "aaa")
        XCTAssertEqual(vm.selectedItem(type: .type), "")
        vm.setSelected(type: .type, item: nil)
        XCTAssertEqual(vm.selectedItem(type: .type), "")
    }
}
