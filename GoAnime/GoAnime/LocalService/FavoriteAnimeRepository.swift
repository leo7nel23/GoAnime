//
//  FavoriteAnimeRepository.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation

protocol FavoriteAnimeRepositoryProtocol {
    func favoriteItems() -> [AnimeItemModel]
    func addFavorite(item: AnimeItemModel) -> AnimeItemModel
    func removeFavorite(item: AnimeItemModel) -> AnimeItemModel
}

class FavoriteAnimeRepository: FavoriteAnimeRepositoryProtocol {
    private static let favoriteItemKey: String = "favoriteItemKey"
    
    private let storage: ItemStorageProtocol
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(storage: ItemStorageProtocol) {
        self.storage = storage
        loadFavorite()
    }
    
    private func loadFavorite() {
        if let items = storage.getItem(for: Self.favoriteItemKey, { data -> [AnimeItemModel]? in
            if let animeItems = try? decoder.decode([AnimeItemModel].self, from: data) {
                return animeItems
            }
            return nil
        }) {
            currentFavoriteItems = items
        }
    }
    
    private var currentFavoriteItems: [AnimeItemModel] = [] {
        didSet {
            if let data = try? encoder.encode(currentFavoriteItems) {
                storage.set(item: data, for: Self.favoriteItemKey)
            }
        }
    }
    
    func favoriteItems() -> [AnimeItemModel] {
        currentFavoriteItems
    }
    
    func addFavorite(item: AnimeItemModel) -> AnimeItemModel {
        guard currentFavoriteItems.first(where: { $0.id == item.id }) == nil else { return item }
        item.isFavorite = true
        currentFavoriteItems.append(item)
        return item
    }
    
    func removeFavorite(item: AnimeItemModel) -> AnimeItemModel {
        guard let item = currentFavoriteItems.first(where: { $0.id == item.id }) else { return item }
        item.isFavorite = false
        currentFavoriteItems.removeAll(where: { $0.id == item.id })
        return item
    }
}
