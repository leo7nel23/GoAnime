//
//  Helper.swift
//  GoAnimeTests
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
@testable import GoAnime

final class Helper {
    static let topAnime: [String: Any] =
    [
        "pagination": [
            "last_visible_page": 1099,
            "has_next_page": true,
            "current_page": 3
        ],
        "data": [
            [
                "mal_id": 4705,
                "url": "https://myanimelist.net/anime/4705/Tengen_Toppa_Gurren_Lagann__Parallel_Works",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/anime/5/10986.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/anime/5/10986t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/anime/5/10986l.jpg"
                    ]
                ],
                "title": "Tengen Toppa Gurren Lagann: Parallel Works",
                "type": "Music",
                "aired": [
                    "from": "2008-06-15T00:00:00+00:00",
                    "to": "2008-09-14T00:00:00+00:00",
                    "prop": [
                        "from": [
                            "day": 15,
                            "month": 6,
                            "year": 2008
                        ],
                        "to": [
                            "day": 14,
                            "month": 9,
                            "year": 2008
                        ]
                    ],
                    "string": "Jun 15, 2008 to Sep 14, 2008"
                ],
                "rank": 3523,
            ],
            [
                "mal_id": 1047,
                "url": "https://myanimelist.net/anime/1047/On_Your_Mark",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/anime/10/81234.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/anime/10/81234t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/anime/10/81234l.jpg"
                    ]
                ],
                "title": "On Your Mark",
                "type": "Music",
                "aired": [
                    "from": "1995-06-29T00:00:00+00:00",
                    "to": nil,
                    "prop": [
                        "from": [
                            "day": 29,
                            "month": 6,
                            "year": 1995
                        ],
                        "to": [
                            "day": nil,
                            "month": nil,
                            "year": nil
                        ]
                    ],
                    "string": "Jun 29, 1995"
                ],
                "rank": 1824,
            ]
        ]
    ]
    
    static let topManga: [String: Any] =
    [
        "pagination": [
            "last_visible_page": 2564,
            "has_next_page": true,
            "current_page": 3,
            "items": [
                "count": 25,
                "total": 64077,
                "per_page": 25
            ]
        ],
        "data": [
            [
                "mal_id": 103851,
                "url": "https://myanimelist.net/manga/103851/5-toubun_no_Hanayome",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/manga/2/201572.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/manga/2/201572t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/manga/2/201572l.jpg"
                    ]
                ],
                "title": "5-toubun no Hanayome",
                "type": "Manga",
                "rank": 768,
                "published": [
                    "from": "2014-04-07T00:00:00+00:00",
                    "to": nil
                ],
            ],
            [
                "mal_id": 70345,
                "url": "https://myanimelist.net/manga/70345/Grand_Blue",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/manga/2/166124.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/manga/2/166124t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/manga/2/166124l.jpg"
                    ],
                ],
                "title": "Grand Blue",
                "type": "Manga",
                "published": [
                    "from": "2014-04-07T00:00:00+00:00",
                    "to": nil
                ],
                "rank": 9
            ]
        ]
    ]
    
    static let topMangaEnd: [String: Any] =
    [
        "pagination": [
            "last_visible_page": 2564,
            "has_next_page": false,
            "current_page": 3,
            "items": [
                "count": 25,
                "total": 64077,
                "per_page": 25
            ]
        ],
        "data": [
            [
                "mal_id": 103851,
                "url": "https://myanimelist.net/manga/103851/5-toubun_no_Hanayome",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/manga/2/201572.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/manga/2/201572t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/manga/2/201572l.jpg"
                    ]
                ],
                "title": "5-toubun no Hanayome",
                "type": "Manga",
                "rank": 768,
                "published": [
                    "from": "2014-04-07T00:00:00+00:00",
                    "to": nil
                ],
            ],
            [
                "mal_id": 70345,
                "url": "https://myanimelist.net/manga/70345/Grand_Blue",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/manga/2/166124.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/manga/2/166124t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/manga/2/166124l.jpg"
                    ],
                ],
                "title": "Grand Blue",
                "type": "Manga",
                "published": [
                    "from": "2014-04-07T00:00:00+00:00",
                    "to": nil
                ],
                "rank": 9
            ]
        ]
    ]
    
    static let topAnimeEnd: [String: Any] =
    [
        "pagination": [
            "last_visible_page": 1099,
            "has_next_page": false,
            "current_page": 3
        ],
        "data": [
            [
                "mal_id": 4705,
                "url": "https://myanimelist.net/anime/4705/Tengen_Toppa_Gurren_Lagann__Parallel_Works",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/anime/5/10986.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/anime/5/10986t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/anime/5/10986l.jpg"
                    ]
                ],
                "title": "Tengen Toppa Gurren Lagann: Parallel Works",
                "type": "Music",
                "aired": [
                    "from": "2008-06-15T00:00:00+00:00",
                    "to": "2008-09-14T00:00:00+00:00",
                    "prop": [
                        "from": [
                            "day": 15,
                            "month": 6,
                            "year": 2008
                        ],
                        "to": [
                            "day": 14,
                            "month": 9,
                            "year": 2008
                        ]
                    ],
                    "string": "Jun 15, 2008 to Sep 14, 2008"
                ],
                "rank": 3523,
            ],
            [
                "mal_id": 1047,
                "url": "https://myanimelist.net/anime/1047/On_Your_Mark",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/anime/10/81234.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/anime/10/81234t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/anime/10/81234l.jpg"
                    ]
                ],
                "title": "On Your Mark",
                "type": "Music",
                "aired": [
                    "from": "1995-06-29T00:00:00+00:00",
                    "to": nil,
                    "prop": [
                        "from": [
                            "day": 29,
                            "month": 6,
                            "year": 1995
                        ],
                        "to": [
                            "day": nil,
                            "month": nil,
                            "year": nil
                        ]
                    ],
                    "string": "Jun 29, 1995"
                ],
                "rank": 1824,
            ]
        ]
    ]
    
}

extension AnimeItemModel {
    static let mock: AnimeItemModel = {
        AnimeItemModel(
            malId: 10,
            url: "url",
            imageUrl: "imageUrl",
            thumbnailUrl: "thumbnailUrl",
            title: "title",
            rank: 100,
            type: .manga(.all, .none),
            fromDate: Date(),
            toDate: Date()
        )
    }()
}
