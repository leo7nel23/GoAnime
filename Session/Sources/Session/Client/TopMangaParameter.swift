//
//  TopMangaParameter.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public struct TopMangaParameter: SessionParameterProtocol {
    public typealias Response = TopMangaModel
    
    public var path: String
    
    public init(
        page: Int,
        limit: Int,
        type: MangaType,
        filter: AnimeFilter
    ) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.jikan.moe"
        components.path = "/v4/top/manga"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            type.urlItem,
            filter.urlItem
        ].compactMap { $0 }
        
        self.path = components.url!.absoluteString
    }
}

public enum MangaType: String, Codable {
    case manga
    case novel
    case lightnovel
    case oneshot
    case doujin
    case manhwa
    case all
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var rawString = try container.decode(String.self)
        
        rawString = rawString.replacingOccurrences(of: " ", with: "")
        if let type = MangaType(rawValue: rawString.lowercased()) {
            self = type
        } else {
            throw SesssionError.responseError(.parseJSONFail("Cannot initialize MangaType from invalid String value \(rawString)"))
        }
    }
    
    fileprivate var urlItem: URLQueryItem? {
        switch self {
        case .all:  return nil
        default: return URLQueryItem(name: "type", value: rawValue)
        }
    }
}

public struct MangaItem: Codable {
    public struct Images: Codable {
        public struct ImagesItem: Codable {
            public var imageUrl: String
            public var smallImageUrl: String
            public var largeImageUrl: String
            
            public init(
                imageUrl: String,
                smallImageUrl: String,
                largeImageUrl: String
            ) {
                self.imageUrl = imageUrl
                self.smallImageUrl = smallImageUrl
                self.largeImageUrl = largeImageUrl
            }
        }
        
        public  var jpg: ImagesItem
        
        public init(
            jpg: MangaItem.Images.ImagesItem
        ) {
            self.jpg = jpg
        }
    }
    
    public struct Published: Codable {
        public var from: Date
        public var to: Date?
        
        public init(
            from: Date,
            to: Date? = nil
        ) {
            self.from = from
            self.to = to
        }
    }
    
    public var malId: Int
    public var url: String
    public var images: Images
    public var title: String
    public var rank: Int
    public var type: MangaType
    public var published: Published
    
    public init(
        malId: Int,
        url: String,
        images: MangaItem.Images,
        title: String,
        rank: Int,
        type: MangaType,
        published: MangaItem.Published
    ) {
        self.malId = malId
        self.url = url
        self.images = images
        self.title = title
        self.rank = rank
        self.type = type
        self.published = published
    }
}


public struct TopMangaModel: Codable {
    public var pagination: Pagination
    public var data: [MangaItem]
    
    public init(
        pagination: Pagination,
        data: [MangaItem]
    ) {
        self.pagination = pagination
        self.data = data
    }
}
