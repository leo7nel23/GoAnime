//
//  AnimeViewController.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/16.
//

import Foundation
import UIKit
import Combine

final class AnimeViewController: UIViewController {
    let viewModel: AnimeViewModel
    private var cancellable: Set<AnyCancellable> = []
    
    private lazy var segment: UISegmentedControl = {
        let s = UISegmentedControl(items: viewModel.segmentItems)
        let tintColor: UIColor = UIColor.systemTeal
        s.selectedSegmentTintColor = tintColor
        s.setTitleTextAttributes([.foregroundColor: tintColor], for: .normal)
        s.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        s.addTarget(self, action: #selector(segmentDidUpdate(_:)), for: .valueChanged)
        s.selectedSegmentIndex = viewModel.segmentSelectedIndex
        return s
    }()
    
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { [weak self] _ in
            self?.viewModel.reloadData()
        }))
        return r
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView(style: .medium)
        i.startAnimating()
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    private enum Section: Hashable {
        case anime
        case loadMore
    }
        
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    private lazy var dataSource: DataSource = makeDataSource()
    
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
    
    private func makeDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, String> { [weak self] cell, indexPath, identifier in
            guard let self = self,
                  self.viewModel.cellConfigurations.count > indexPath.item else {
                return
            }
            cell.contentConfiguration = self.viewModel.cellConfigurations[indexPath.item]
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
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
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        let barItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchDidSelect(_:))
        )
        navigationItem.rightBarButtonItem = barItem
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
    }
    
    func bindPublishers() {
        viewModel
            .$cellConfigurations
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] configurations in
                guard let self = self else { return }
                print("reload $cellViewModels")
                var snapshot = Snapshot()
                snapshot.appendSections([.anime])
                snapshot.appendItems(configurations.map(\.id), toSection: .anime)

                self.dataSource.apply(snapshot)
                self.refreshControl.endRefreshing()
            })
            .store(in: &cancellable)
        
        viewModel
            .$loadMoreState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .none, .finished:
                    self?.indicator.isHidden = true
                case .loading:
                    self?.indicator.isHidden = false
                case .error(let text):
                    print("Error: \(text)")
                }
            }
            .store(in: &cancellable)
    }
}

// Action
extension AnimeViewController {
    @objc func searchDidSelect(_ sender: UIBarButtonItem) {
    }
    
    @objc func segmentDidUpdate(_ sender: UISegmentedControl) {
        viewModel.segmentDidSelect(at: sender.selectedSegmentIndex)
    }
}

extension AnimeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.userDidTap(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let identifiers = dataSource.snapshot().itemIdentifiers(inSection: .anime)
        guard let lastIdentifier = identifiers.last else {
            return
        }
        
        let identifier = dataSource.snapshot().itemIdentifiers(inSection: .anime)[indexPath.item]
        
        if identifier == lastIdentifier {
            viewModel.loadMore()
        }
    }
}
