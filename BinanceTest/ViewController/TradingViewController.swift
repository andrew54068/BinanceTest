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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.delegate = self
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        collectionView.pinToSuper(edge: .zero)
        collectionView.register(TradingCollectionViewCell.self,
                                forCellWithReuseIdentifier: TradingCollectionViewCell.className)
        collectionView.register(TradingCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: TradingCollectionViewHeader.className)
    }
    
}

extension TradingViewController: TradingViewModelDelegate {
    
    func ReceiveNewData() {
        collectionView.reloadData()
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
                    precisionOrder: 4)
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
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
}
