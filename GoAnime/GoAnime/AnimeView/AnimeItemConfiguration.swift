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

final class AnimeItemConfiguration: UIContentConfiguration, Identifiable {
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
    @Published var isFavorite: Bool
    
    
    init(model: AnimeItemModel) {
        self.model = model
        self.isFavorite = model.isFavorite
    }
    
    func makeContentView() -> UIView & UIContentView {
        AnimeItemContentView(
            self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
    func favoriteDidTapped() {
        isFavorite = !isFavorite
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

final class AnimeItemContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            guard let config = configuration as? AnimeItemConfiguration else { return }
            configure(with: config)
        }
    }
    
    private let imageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        i.backgroundColor = .systemGray6
        return i
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .preferredFont(forTextStyle: .headline)
        l.textColor = .systemTeal
        
        return l
    }()
    
    private let rankLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .title1)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        
        return l
    }()
    
    private let typeLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .caption1)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .caption1)
        l.textColor = .secondaryLabel
        return l
    }()
    private let addToFavoriteButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "heart"), for: .normal)
        b.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        return b
        
    }()
    
    var cancellable: AnyCancellable?
    
    init(_ configuration: AnimeItemConfiguration) {
        self.configuration = configuration
        
        super.init(frame: .zero)
        
        let infoStack: UIStackView = {
            let s = UIStackView(arrangedSubviews: [titleLabel, typeLabel, dateLabel])
            s.axis = .vertical
            s.alignment = .leading
            s.spacing = 4
            return s
        }()
        
        let itemStack: UIStackView = {
            let s = UIStackView(arrangedSubviews: [imageView, infoStack])
            s.axis = .horizontal
            s.alignment = .top
            s.spacing = 8
            return s
        }()
        
        let allStack: UIStackView = {
            let s = UIStackView(arrangedSubviews: [rankLabel, itemStack, addToFavoriteButton])
            s.axis = .horizontal
            s.alignment = .center
            s.spacing = 8
            
            return s
        }()
        allStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(allStack)
        
        let bottom = allStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        bottom.priority = .defaultLow
                
        NSLayoutConstraint.activate([
            allStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            allStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 8),
            allStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -8),
            bottom,
            
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.5),
        ])
        
        configure(with: configuration)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with config: AnimeItemConfiguration) {
        imageView.setImage(config.imageUrl)
        rankLabel.text = "\(config.rank)"
        titleLabel.text = config.title
        dateLabel.text = config.dateText
        typeLabel.text = config.type
        addToFavoriteButton.isSelected = config.isFavorite
        
        cancellable = config
            .$isFavorite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.addToFavoriteButton.isSelected = $0
            }
    }
    
    @objc func addFavoriteDidTapped(_ sender: UIButton) {
        guard let config = configuration as? AnimeItemConfiguration else { return }
        config.favoriteDidTapped()
    }
}


extension NSLayoutConstraint {
    
    func priority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
