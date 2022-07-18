//
//  AnimeItemConfiguration.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import UIKit
import Utility
import Combine

protocol AnimeItemConfigurationDelegate: AnyObject {
    func configuration(_ config: AnimeItemConfiguration, didTapFavorite model: AnimeItemModel)
}

final class AnimeItemConfiguration: UIContentConfiguration, Identifiable {
    weak var delegate: AnimeItemConfigurationDelegate?
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()
    
    let model: AnimeItemModel
    
    var id: String { model.id }
    var imageUrl: String { model.imageUrl }
    var title: String { model.title }
    var type: String { model.type.rawValue }
    var rank: Int { model.rank }
    var fromDate: Date? { model.fromDate }
    var toDate: Date? { model.toDate }
    @Published var hideRank: Bool = false
    @Published var isFavorite: Bool
    
    
    init(model: AnimeItemModel) {
        self.model = model
        self.isFavorite = model.isFavorite
    }
    
    func makeContentView() -> UIView & UIContentView {
        AnimeItemContentView(self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
    func favoriteDidTapped() {
        isFavorite = !isFavorite
        delegate?.configuration(self, didTapFavorite: model)
    }
    
    var dateText: String {
        let from = Self.dateFormatter.animeString(from: fromDate)
        let to = Self.dateFormatter.animeString(from: toDate)
        return [from, to].joined(separator: " ~ ")
    }
}

extension DateFormatter {
    func animeString(from date: Date?) -> String {
        guard let date = date else { return "-" }
        return string(from: date)
    }
}
