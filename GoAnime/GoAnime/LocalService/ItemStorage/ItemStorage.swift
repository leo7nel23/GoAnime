//
//  ItemStorage.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation

protocol ItemStorageProtocol {
    func set(item: Data, for key: String)
    func getItem(for key: String) -> Data?
    func getItem<T>(for key: String, _ mapper: ((Data) -> T?)) -> T?
}
