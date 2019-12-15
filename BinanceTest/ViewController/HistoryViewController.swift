//
//  HistoryViewController.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/16.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import Starscream
import RainKit

final class HistoryViewController: UIViewController {
    
    lazy var viewModel: HistoryViewModel = HistoryViewModel()
    
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
    
    private lazy var quantityFormatter: NumberFormatter = {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.delegate = self
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        
        collectionView.pinToSuper(edge: .zero)
        
        collectionView.register(HistoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: HistoryCollectionViewCell.className)
        collectionView.register(HistoryCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: HistoryCollectionViewHeader.className)
    }
    
}

extension HistoryViewController: HistoryViewModelDelegate {
    
    func ReceiveNewData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItem()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HistoryCollectionViewCell = collectionView.dequeueReusableCell(with: HistoryCollectionViewCell.self,
                                                                                 indexPath: indexPath)
        let model: AggregateTradeModel = viewModel.historyModels(by: indexPath)
        
        cell.setup(time: model.getTradeTime(),
                   price: model.price,
                   quantity: quantityFormatter.string(from: NSNumber(value: (Double(model.quantity) ?? 0))) ?? "",
                   isMarketMaker: model.isMarketMaker)
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
            let header: HistoryCollectionViewHeader = collectionView.dequeueReusableHeaderCell(with: HistoryCollectionViewHeader.self,
                                                                                               indexPath: indexPath)
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
}
