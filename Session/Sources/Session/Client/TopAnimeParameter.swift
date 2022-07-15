//
//  TopAnimeParameter.swift
//  
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public struct TopAnimeParameter: SessionParameterProtocol {
    public typealias Response = TopAnimeModel
    
    public var path: String
    
    init(page: Int, limit: Int, type: AnimeType, filter: AnimeFilter) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.jikan.moe"
        components.path = "/v4/top/anime"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            type.urlItem,
            filter.urlItem
        ].compactMap { $0 }
        
        self.path = components.url!.absoluteString
    }
}

public enum AnimeType: String, Codable {
    case tv
    case movie
    case ova
    case special
    case ona
    case music
    case all
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        
        if let type = AnimeType(rawValue: rawString.lowercased()) {
            self = type
        } else {
            throw SesssionError.responseError(.parseJSONFail("Cannot initialize AnimeType from invalid String value \(rawString)"))
        }
    }
    
    fileprivate var urlItem: URLQueryItem? {
        switch self {
        case .all:  return nil
        default: return URLQueryItem(name: "type", value: rawValue)
        }
    }
}

public struct AnimeItem: Codable {
    public struct Images: Codable {
        public struct ImagesItem: Codable {
            public var imageUrl: String
            public var smallImageUrl: String
            public var largeImageUrl: String
        }
        public  var jpg: ImagesItem
    }
    
    public struct Aired: Codable {
        var from: Date
        var to: Date?
    }
    
    public var malId: Int
    public var url: String
    public var images: Images
    public var title: String
    public var rank: Int
    public var type: AnimeType
    public var aired: Aired
}


public struct TopAnimeModel: Codable {
    public var pagination: Pagination
    public var data: [AnimeItem]
}
