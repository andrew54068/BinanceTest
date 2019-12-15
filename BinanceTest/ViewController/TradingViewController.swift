//
//  TradingViewController.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import Starscream
import RainKit

final class TradingViewController: UIViewController {
    
    lazy var viewModel: TradingViewModel = TradingViewModel()
    
    private let cellHeight: CGFloat = 30
    
    private lazy var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        .itemSize(CGSize(width: view.bounds.width,
                         height: cellHeight))
        .scrollDirection(.vertical)
        .minimumLineSpacing(0)
        .minimumInteritemSpacing(0)
    
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                 collectionViewLayout: layout)
        .delegate(self)
        .dataSource(self)
        .backgroundColor(.black)
    
    lazy var precisionSelectionBackgroundButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle(nil, for: .normal)
        button.isHidden = true
        button.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        button.addTarget(self, action: #selector(hideSelectionView), for: .touchUpInside)
        return button
    }()
    
    lazy var precisionSelectionStackView: UIStackView = UIStackView()
        .distribution(.fillEqually)
        .alignment(.fill)
        .axis(.vertical)
        .backgroundColor(.black)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.delegate = self
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        view.addSubview(precisionSelectionBackgroundButton)
        precisionSelectionBackgroundButton.addSubview(precisionSelectionStackView)
        
        collectionView.pinToSuper(edge: .zero)
        
        collectionView.register(TradingCollectionViewCell.self,
                                forCellWithReuseIdentifier: TradingCollectionViewCell.className)
        collectionView.register(TradingCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: TradingCollectionViewHeader.className)
        
        precisionSelectionBackgroundButton.pinToSuper(edge: .zero)
        precisionSelectionStackView.anchor(\.topAnchor, to: precisionSelectionBackgroundButton.topAnchor, constant: 30)
            .anchor(\.trailingAnchor, to: precisionSelectionBackgroundButton.trailingAnchor, constant: -15)
            .anchor(\.widthAnchor, to: 80)
        
        setupBottonSelection(heighestPrecision: viewModel.precisionDigit)
    }
    
    private func setupBottonSelection(heighestPrecision: Int) {
        var selections: [Int] = []
        for precision in 0...heighestPrecision {
            selections.append(precision)
        }
        selections = Array(selections.reversed().prefix(4)).reversed()
        selections.forEach {
            let button: UIButton = UIButton()
                .title(String($0), for: .normal)
                .tag($0)
                .backgroundColor(.black)
            button.addTarget(self, action: #selector(precisionSelected), for: .touchUpInside)
            precisionSelectionStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func hideSelectionView(_ sender: UIButton) {
        precisionSelectionBackgroundButton.isHidden = true
    }
    
    func connet() {
        viewModel.connet()
    }
    
}

extension TradingViewController: TradingViewModelDelegate {
    
    func ReceiveNewData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
}

extension TradingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItem()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TradingCollectionViewCell = collectionView.dequeueReusableCell(with: TradingCollectionViewCell.self,
                                                                                 indexPath: indexPath)
        let offerModels: (bid: OfferModel?, ask: OfferModel?) = viewModel.offerModels(by: indexPath)

        cell.update(bidModel: offerModels.bid,
                    askModel: offerModels.ask,
                    precisionOrder: 4 - (8 - viewModel.precisionDigitSelected))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header: TradingCollectionViewHeader = collectionView.dequeueReusableHeaderCell(with: TradingCollectionViewHeader.self,
                                                                                               indexPath: indexPath)
            header.setupBottonSelection(currentSelected: viewModel.precisionDigitSelected)
            header.delegate = self
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
}

extension TradingViewController: TradingCollectionViewHeaderDelegate {
    
    func precisionOptionDisplay() {
        precisionSelectionBackgroundButton.isHidden = false
    }
    
    @objc private func precisionSelected(_ sender: UIButton) {
        viewModel.precisionDigitSelected = sender.tag
        precisionSelectionBackgroundButton.isHidden = true
        if let header: TradingCollectionViewHeader = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                                                                      at: IndexPath(item: 0, section: 0)) as? TradingCollectionViewHeader {
            header.percisionBotton.setTitle(String(sender.tag), for: .normal)
        }
    }
    
}
