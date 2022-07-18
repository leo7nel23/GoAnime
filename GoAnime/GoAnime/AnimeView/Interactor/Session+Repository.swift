//
//  Session+Repository.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
import Session
import Combine
import TestHelper

protocol AnimeRepositoryProtocol {
    func topAnime(
        type: AnimeItemType,
        page: Int,
        mockData: DataConvertible?
    ) -> AnyPublisher<AnimeItemInfoModel, Error>
}

extension Session: AnimeRepositoryProtocol {
    func topAnime(
        type: AnimeItemType,
        page: Int,
        mockData: DataConvertible? = nil
    ) -> AnyPublisher<AnimeItemInfoModel, Error> {
        switch type {
        case .anime(let animeType, let animeFilter):
            let parameter = TopAnimeParameter(page: page, limit: 50, type: animeType, filter: animeFilter)
            parameter.registerMockIfNeeded(with: mockData)
            return request(parameter)
                .map { $0.asAnimeItemInfo(filter: animeFilter) }
                .eraseToAnyPublisher()
            
        case .manga(let mangaType, let animeFilter):
            let parameter = TopMangaParameter(page: page, limit: 50, type: mangaType, filter: animeFilter)
            parameter.registerMockIfNeeded(with: mockData)
            return request(parameter)
                .map { $0.asAnimeItemInfo(filter: animeFilter) }
                .eraseToAnyPublisher()
            
        case .favorite:
            fatalError("DO NOT Support")
        }
    }
}

extension TopAnimeModel {
    func asAnimeItemInfo(filter: AnimeFilter) -> AnimeItemInfoModel {
        AnimeItemInfoModel(
            currentPage: pagination.currentPage,
            hasNextPage: pagination.hasNextPage,
            animeItems: data.map { $0.asAnimeItemModel(filter: filter ) }
        )
    }
}

extension AnimeItem {
    func asAnimeItemModel(filter: AnimeFilter) -> AnimeItemModel {
        AnimeItemModel(
            malId: malId,
            url: url,
            imageUrl: images.jpg.imageUrl,
            thumbnailUrl: images.jpg.smallImageUrl,
            title: title,
            rank: rank,
            type: .anime(type, filter),
            fromDate: aired.from,
            toDate: aired.to
        )
    }
}

extension TopMangaModel {
    func asAnimeItemInfo(filter: AnimeFilter) -> AnimeItemInfoModel {
        AnimeItemInfoModel(
            currentPage: pagination.currentPage,
            hasNextPage: pagination.hasNextPage,
            animeItems: data.map { $0.asAnimeItemModel(filter: filter )}
        )
    }
}

extension MangaItem {
    func asAnimeItemModel(filter: AnimeFilter) -> AnimeItemModel {
        AnimeItemModel(
            malId: malId,
            url: url,
            imageUrl: images.jpg.imageUrl,
            thumbnailUrl: images.jpg.smallImageUrl,
            title: title,
            rank: rank,
            type: .manga(type, filter),
            fromDate: published.from,
            toDate: published.to
        )
    }
}

extension SessionParameterProtocol {
    func registerMockIfNeeded(with mockData: DataConvertible?) {
        #if DEBUG
        if let mockData = mockData {
            MockAPI(parameter: self, data: mockData).register()
        }
        #endif
    }
}
