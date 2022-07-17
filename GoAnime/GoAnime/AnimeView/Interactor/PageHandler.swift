//
//  PageHandler.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation

extension AnimeItemType: Hashable {}

final class PageHandler {
    struct PageInfo {
        var page: Int
        var hasNextPage: Bool
    }
    var pageInfo: [AnimeItemType: PageInfo] = [:]
    
    func currentPageInfo(for type: AnimeItemType) -> PageInfo {
        if let info = pageInfo[type] {
            return info
        } else {
            let info = PageInfo(page: 0, hasNextPage: true)
            pageInfo[type] = info
            return info
        }
    }
    
    func setPageInfo(page: Int, hasNextPage: Bool, type: AnimeItemType) {
        pageInfo[type] = PageInfo(page: page, hasNextPage: hasNextPage)
    }
}
