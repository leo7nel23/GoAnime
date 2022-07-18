//
//  FilterViewController.swift
//  GoAnime
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import UIKit
import Utility

final class FilterViewController: UIViewController {
    private let viewModel: FilterViewModel
    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        return v
    }()
    
    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var confirmButton: UIButton = {
        let b = basicButton()
        b.setTitle("Confirm", for: .normal)
        b.backgroundColor = .systemTeal
        b.setTitleColor(.white, for: .normal)
        return b
    }()
    
    private lazy var cleanButton: UIButton = {
        let b = basicButton()
        b.setTitle("Clear", for: .normal)
        b.backgroundColor = .white
        b.setTitleColor(.systemTeal, for: .normal)
        return b
    }()
    
    private var buttons: [FilterType: [UIButton]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.3)
        setupView()
        bindAction()
    }
    
    @objc func stopFilter(_ gesture: UITapGestureRecognizer) {
        viewModel.stop()
    }
    
    func bindAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(stopFilter(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        buttons.forEach {
            let selected = self.viewModel.selectedItem(type: $0.key)
            let button = $0.value.first { $0.title(for: .normal) == selected }
            button?.isSelected = true
        }
        
        cleanButton
            .addAction(
                UIAction { [weak self] _ in
                    self?.buttons.forEach { $0.value.forEach { $0.isSelected = false } }
                },
                for: .touchUpInside
        )
        
        FilterType
            .allCases
            .forEach { [weak self] type in
                guard let buttons = self?.buttons[type] else { return }
                buttons.enumerated().forEach { (index, button) in
                    button.addAction(
                        UIAction { _ in
                            self?.buttonTap(at: index, type: type)
                        },
                        for: .touchUpInside
                    )
                }
            }
        
        confirmButton
            .addAction(
                UIAction { [weak self] _ in
                    self?
                        .buttons
                        .forEach {
                            guard let selected = $0.value.first(where: { $0.isSelected }) else { return }
                            self?.viewModel.setSelected(type: $0.key, item: selected.title(for: .normal))
                    }
                    self?.viewModel.animeTypeChecked()
                },
                for: .touchUpInside
            )
    }
    
    private func buttonTap(at index: Int, type: FilterType) {
        guard let buttons = buttons[type],
              buttons.count > index else {
            return
        }
        buttons
            .enumerated()
            .forEach {
                $0.element.isSelected = $0.offset == index
                ? !$0.element.isSelected
                : false
            }
    }
    
    private func basicButton(text: String? = nil, tintColor: UIColor = .systemTeal) -> UIButton {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.borderColor = tintColor.cgColor
        b.layer.borderWidth = 1.0
        b.layer.cornerRadius = 5
        
        return b
    }
    
    private func setupView() {
        view.addSubview(contentView)
        
        func filterStack(with viewModel: FilterContentViewModel) -> ([UIButton], UIStackView) {
            let titleLabel: UILabel = {
                let l = UILabel()
                l.text = viewModel.type.title
                l.textAlignment = .left
                l.font = .preferredFont(forTextStyle: .headline)
                
                return l
            }()
            
            func button(text: String) -> UIButton {
                let b = basicButton()
                b.setTitle(text, for: .normal)
                b.setTitleColor(.systemTeal, for: .normal)
                b.setTitleColor(.white, for: .selected)
                b.titleLabel?.adjustsFontSizeToFitWidth = true
                b.setBackgroundImage(UIImage(color: .systemTeal), for: .selected)
                b.setBackgroundImage(UIImage(color: .systemBackground), for: .normal)
                b.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                
                return b
            }
            
            let allBtn = viewModel.detail.map { button(text: $0) }
            let reshapeButtons = allBtn.enumerated().reduce([[UIButton]]()) { partialResult, next in
                var result = partialResult
                var last = result.last ?? []
                
                if last.count < 2 {
                    last.append(next.element)
                    if result.count > 0 {
                        result.removeLast()
                    }
                    result.append(last)
                } else {
                    result.append([next.element])
                }
                
                return result
            }
            
            let buttonStacks: [UIStackView] = reshapeButtons.map {
                let stack = UIStackView(arrangedSubviews: $0)
                stack.axis = .horizontal
                stack.alignment = .fill
                stack.distribution = .fillEqually
                stack.spacing = 8
                
                return stack
            }
            
            var allView: [UIView] = [titleLabel]
            allView.append(contentsOf: buttonStacks)
            
            let stack: UIStackView = {
                let s = UIStackView(arrangedSubviews: allView)
                s.axis = .vertical
                s.alignment = .fill
                s.spacing = 8
                return s
            }()
            
            return (allBtn, stack)
        }
        
        var stacks: [UIStackView] = []
        if let typeModel = viewModel.typeModel {
            let items = filterStack(with: typeModel)
            buttons[.type] = items.0
            stacks.append(items.1)
        }
        
        if let filterModel = viewModel.filterModel {
            let items = filterStack(with: filterModel)
            buttons[.filter] = items.0
            stacks.append(items.1)
        }
        
        let filterStack = UIStackView(arrangedSubviews: stacks)
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        filterStack.axis = .vertical
        filterStack.alignment = .fill
        filterStack.distribution = .fillEqually
        filterStack.spacing = 16
        contentView.addSubview(filterStack)
        
        let btnStack = UIStackView(arrangedSubviews: [cleanButton, confirmButton])
        btnStack.translatesAutoresizingMaskIntoConstraints = false
        btnStack.alignment = .center
        btnStack.axis = .horizontal
        btnStack.distribution = .fillEqually
        btnStack.spacing = 16
        contentView.addSubview(btnStack)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            filterStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 16),
            filterStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -16),
            filterStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            
            btnStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            btnStack.leadingAnchor.constraint(equalTo: filterStack.leadingAnchor),
            btnStack.trailingAnchor.constraint(equalTo: filterStack.trailingAnchor)
        ])
    }
}

extension FilterViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}
