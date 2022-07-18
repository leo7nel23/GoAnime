//
//  FilterViewModel.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import Session

enum FilterType: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    
    case type
    case filter
    
    var title: String {
        switch self {
        case .type:     return "Type"
        case .filter:   return "Filter"
        }
    }
}

final class FilterContentViewModel {
    var type: FilterType
    var detail: [String]
    
    init(type: FilterType, types: [String]) {
        self.type = type
        self.detail = types
    }
}

final class FilterViewModel {
    weak var coordinator: FilterCoordinator?
    weak var deleage: FilterViewModelDelegate?
    
    private var animeItemType: AnimeItemType
    private var animeFilter: AnimeFilter = .none
    private var mangaType: MangaType = .all
    private var animeType: AnimeType = .all
    
    init(
        coordinator: FilterCoordinator,
        animeType: AnimeItemType
    ) {
        self.coordinator = coordinator
        self.animeItemType = animeType
        initFilterType()
    }
    
    func initFilterType() {
        switch animeItemType {
        case .anime(let animeType, let animeFilter):
            self.animeType = animeType
            self.animeFilter = animeFilter
        case .manga(let mangaType, let animeFilter):
            self.mangaType = mangaType
            self.animeFilter = animeFilter
        case .favorite:
            break
        }
    }
    
    var typeModel: FilterContentViewModel? {
        switch animeItemType {
        case .anime:
            return FilterContentViewModel(type: .type, types: AnimeType.types())
        case .manga:
            return FilterContentViewModel(type: .type, types: MangaType.types())
        case .favorite:
            return nil
        }
    }
    
    var filterModel: FilterContentViewModel? {
        return animeItemType.isFavorit
        ? nil
        : FilterContentViewModel(type: .filter, types: AnimeFilter.types())
    }
    
    func setSelected(type: FilterType, item: String?) {
        switch type {
        case .type:
            switch animeItemType {
            case .anime:
                guard let item = item else {
                    animeType = .all
                    return
                }
                animeType = AnimeType(rawValue: item) ?? .all
            case .manga:
                guard let item = item else {
                    mangaType = .all
                    return
                }
                mangaType = MangaType(rawValue: item) ?? .all
            case .favorite:
                break
            }
            
            
        case .filter:
            guard let item = item else {
                animeFilter = .none
                return
            }
            
            animeFilter = AnimeFilter(rawValue: item) ?? .none
        }
    }
    
    func selectedItem(type: FilterType) -> String {
        switch type {
        case .type:
            switch animeItemType {
            case .anime:
                return animeType.rawValue
            case .manga:
                return mangaType.rawValue
            case .favorite:
                return ""
            }
        case .filter:
            return animeFilter.rawValue
        }
    }
    
    func animeTypeChecked() {
        switch animeItemType {
        case .anime:
            deleage?.viewModel(self, didCheckd: .anime(animeType, animeFilter))
        case .manga:
            deleage?.viewModel(self, didCheckd: .manga(mangaType, animeFilter))
        case .favorite:
            deleage?.viewModel(self, didCheckd: .favorite(.all))
        }
        stop()
    }
    
    func stop() {
        coordinator?.stop()
    }
}

extension AnimeType {
    static func types() -> [String] {
        AnimeType.allCases.map { $0.rawValue }.sorted().filter { $0 != "all" }
    }
}

extension AnimeFilter {
    static func types() -> [String] {
        AnimeFilter.allCases.map { $0.rawValue }.sorted().filter { $0 != "none" }
    }
}

extension MangaType {
    static func types() -> [String] {
        MangaType.allCases.map { $0.rawValue }.sorted().filter { $0 != "all" }
    }
}
