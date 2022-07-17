//
//  UserDefault+ItemStorage.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation

extension UserDefaults: ItemStorageProtocol {
    func set(item: Data, for key: String) {
        set(item, forKey: key)
    }
    
    func getItem(for key: String) -> Data? {
        data(forKey: key)
    }
    
    func getItem<T>(for key: String, _  mapper: ((Data) -> T?)) -> T? {
        guard let data = getItem(for: key) else { return nil }
        return mapper(data)
    }
}
