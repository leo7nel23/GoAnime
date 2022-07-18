//
//  AnimeItemInfoModel.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
import Session

final class AnimeItemInfoModel: Codable {
    var currentPage: Int = 0
    var hasNextPage: Bool = false
    var animeItems: [AnimeItemModel] = []
    
    init(
        currentPage: Int,
        hasNextPage: Bool,
        animeItems: [AnimeItemModel]
    ) {
        self.currentPage = currentPage
        self.hasNextPage = hasNextPage
        self.animeItems = animeItems
    }
}

final class AnimeItemModel: Codable, Identifiable {
    lazy var id: String = "\(self.malId)"
    var isFavorite: Bool = false
    
    var malId: Int
    var url: String
    var imageUrl: String
    var thumbnailUrl: String
    var title: String
    var rank: Int?
    var type: AnimeItemType
    var fromDate: Date?
    var toDate: Date?
    
    init(
        malId: Int,
        url: String,
        imageUrl: String,
        thumbnailUrl: String,
        title: String,
        rank: Int?,
        type: AnimeItemType,
        fromDate: Date?,
        toDate: Date?
    ) {
        self.malId = malId
        self.url = url
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.title = title
        self.rank = rank
        self.type = type
        self.fromDate = fromDate
        self.toDate = toDate
    }
}

extension AnimeItemType: RawRepresentable {
    init?(rawValue: String) {
        let strings = rawValue.split(separator: "_").map { String($0) }
        guard strings.count == 3 else { return nil }
        switch strings[0] {
        case "Anime":
            guard let animeType = AnimeType(rawValue: strings[1]),
                  let filter = AnimeFilter(rawValue: strings[2]) else {
                return nil
            }
            self = .anime(animeType, filter)
                                      
        case "Manga":
            guard let mangaType = MangaType(rawValue: strings[1]),
                  let filter = AnimeFilter(rawValue: strings[2]) else {
                return nil
            }
            self = .manga(mangaType, filter)
            
        case "Favorite":
            if rawValue == "Favorite_Manga_Anime" {
                self = .favorite(.all)
                return
            }
            
            guard let filter = AnimeFilter(rawValue: strings[2]) else {
                return nil
            }
            
            if let animeType = AnimeType(rawValue: strings[1]) {
                self = .favorite(.anime(animeType, filter))
            } else if let mangaType = MangaType(rawValue: strings[1]) {
                self = .favorite(.manga(mangaType, filter))
            } else {
                return nil
            }
            
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .anime(let animeType, let animeFilter):
            return "Anime_\(animeType.rawValue)_\(animeFilter.rawValue)"
        case .manga(let mangaType, let animeFilter):
            return "Manga_\(mangaType.rawValue)_\(animeFilter.rawValue)"
        case .favorite(let favoriteType):
            switch favoriteType {
            case .anime(let animeType, let animeFilter):
                return "Favorite_Anime_\(animeType.rawValue)_\(animeFilter.rawValue)"
            case .manga(let mangaType, let animeFilter):
                return "Favorite_Manga_\(mangaType.rawValue)_\(animeFilter.rawValue)"
            case .all:
                return "Favorite_Manga_Anime"
            }
        }
    }
}

extension AnimeItemType: Equatable {
    public static func == (lhs: AnimeItemType, rhs: AnimeItemType) -> Bool {
        switch (lhs, rhs) {
        case (.anime(let lAnimeType, let lAnimeFilter), .anime(let rAnimeType, let rAnimeFilter)):
            return lAnimeType == rAnimeType && lAnimeFilter == rAnimeFilter
        case (.manga(let lMangaType, let lAnimeFilter), .manga(let rMangaType, let rAnimeFilter)):
            return lMangaType == rMangaType && lAnimeFilter == rAnimeFilter
        case (.favorite(let lFavorite), .favorite(let rFavorite)):
            return lFavorite == rFavorite
        default:
            return false
        }
    }
}

extension AnimeItemType.FavoriteType: Equatable {
    static func == (lhs: AnimeItemType.FavoriteType, rhs: AnimeItemType.FavoriteType) -> Bool {
        switch (lhs, rhs) {
        case (.anime(let lAnimeType, let lAnimeFilter), .anime(let rAnimeType, let rAnimeFilter)):
            return lAnimeType == rAnimeType && lAnimeFilter == rAnimeFilter
        case (.manga(let lMangaType, let lAnimeFilter), .manga(let rMangaType, let rAnimeFilter)):
            return lMangaType == rMangaType && lAnimeFilter == rAnimeFilter
        case (.all, .all):
            return true
        default:
            return false
        }
        
    }
}
