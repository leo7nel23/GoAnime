//
//  FilterCoordinator.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import UIKit

protocol FilterViewModelDelegate: AnyObject {
    func viewModel(_ model: FilterViewModel, didCheckd type: AnimeItemType)
}

final class FilterCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var animeType: AnimeItemType = .anime(.all, .none)
    private var filterVC: FilterViewController?
    private weak var delegate: FilterViewModelDelegate?
    
    init(
        presenter: UINavigationController
    ) {
        self.presenter = presenter
    }
    
    func updateAnimeType(animeType: AnimeItemType) {
        self.animeType = animeType
    }
    func update(delegate: FilterViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        let vm = FilterViewModel(
            coordinator: self,
            animeType: animeType
        )
        vm.deleage = delegate
        let vc = FilterViewController(viewModel: vm)
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presenter.present(vc, animated: true)
        filterVC = vc
    }
    
    func stop() {
        filterVC?.dismiss(animated: true)
    }
}
