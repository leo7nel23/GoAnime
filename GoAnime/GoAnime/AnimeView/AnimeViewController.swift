//
//  AnimeViewController.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import UIKit
import Combine

class AnimeViewController: UIViewController {
    let viewModel: AnimeViewModel
    private var cancellable: Set<AnyCancellable> = []
    
    private lazy var segment: UISegmentedControl = {
        let s = UISegmentedControl(items: viewModel.segmentItems)
        let tintColor: UIColor = UIColor.systemTeal
        s.selectedSegmentTintColor = tintColor
        s.setTitleTextAttributes([.foregroundColor: tintColor], for: .normal)
        s.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return s
    }()
    
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    init(viewModel: AnimeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindPublishers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.title
    }
    
    func setupView() {
        let stack: UIStackView = {
            let s = UIStackView(arrangedSubviews: [segment, collectionView])
            s.translatesAutoresizingMaskIntoConstraints = false
            s.alignment = .center
            s.axis = .vertical
            s.spacing = 8
            return s
        }()
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        let barItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchDidSelect(_:))
        )
        navigationItem.rightBarButtonItem = barItem
    }
    
    func bindPublishers() {
        viewModel
            .$segmentSelectedIndex
            .sink { [weak self] in
                self?.segment.selectedSegmentIndex = $0
            }
            .store(in: &cancellable)
    }
}

// Action
extension AnimeViewController {
    @objc func searchDidSelect(_ sender: UIBarButtonItem) {
    }
}
