//
//  AnimeModel.swift
//  
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public enum AnimeFilter: String, Codable {
    case airing
    case upcoming
    case bypopularity
    case favorite
    case none
    
    var urlItem: URLQueryItem? {
        switch self {
        case .none:  return nil
        default: return URLQueryItem(name: "filter", value: rawValue)
        }
    }
}

public struct Pagination: Codable {
    public var lastVisiblePage: Int
    public var hasNextPage: Bool
    public var currentPage: Int
    
    public init(lastVisiblePage: Int,
         hasNextPage: Bool,
         currentPage: Int
    ) {
        self.lastVisiblePage = lastVisiblePage
        self.hasNextPage = hasNextPage
        self.currentPage = currentPage
    }
}
