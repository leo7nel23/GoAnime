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
    private var currentViewController: FilterViewController?
    
    init(
        presenter: UINavigationController
    ) {
        self.presenter = presenter
    }
    
    func start(animeType: AnimeItemType, delegate: FilterViewModelDelegate?) {
        let vm = FilterViewModel(
            coordinator: self,
            animeType: animeType
        )
        vm.deleage = delegate
        let vc = FilterViewController(viewModel: vm)
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presenter.present(vc, animated: true)
        currentViewController = vc
    }
    
    func stop() {
        currentViewController?.dismiss(animated: true)
    }
}
