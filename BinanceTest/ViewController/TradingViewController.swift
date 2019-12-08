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
    
    private lazy var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        .itemSize(CGSize(width: view.bounds.width,
                         height: 20))
        .scrollDirection(.vertical)
    
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
    }
    
}

extension TradingViewController: TradingViewModelDelegate {
    
    func ReceiveNewData() {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
}

extension TradingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItem()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TradingCollectionViewCell = collectionView.dequeueReusableCell(with: TradingCollectionViewCell.self, indexPath: indexPath)
        let offerModels: (bid: OfferModel?, ask: OfferModel?) = viewModel.offerModels(by: indexPath)
        cell.update(bidModel: offerModels.bid,
                    askModel: offerModels.ask)
        return cell
    }
    
}
