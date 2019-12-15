//
//  HistoryCollectionViewCell.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/16.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import RainKit

enum TradeAction {
    case buy
    case sell
}

final class HistoryCollectionViewCell: UICollectionViewCell {
    
    private let fontSize: CGFloat = 15
    
    lazy var timeTitleLabel: UILabel = self.createTitleLabel(size: fontSize)
    lazy var priceTitleLabel: UILabel = self.createTitleLabel(size: fontSize)
    lazy var quantityTitleLabel: UILabel = self.createTitleLabel(size: fontSize)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(timeTitleLabel)
        addSubview(priceTitleLabel)
        addSubview(quantityTitleLabel)
        
        timeTitleLabel.anchor(\.leadingAnchor, to: self.leadingAnchor, constant: 5)
            .anchor(\.topAnchor, to: self.topAnchor)
            .anchor(\.bottomAnchor, to: self.bottomAnchor)
        
        priceTitleLabel.anchor(\.leadingAnchor, to: self.centerXAnchor, constant: -80)
            .anchor(\.topAnchor, to: self.topAnchor)
            .anchor(\.bottomAnchor, to: self.bottomAnchor)
        
        quantityTitleLabel.anchor(\.trailingAnchor, to: self.trailingAnchor, constant: -5)
            .anchor(\.topAnchor, to: self.topAnchor)
            .anchor(\.bottomAnchor, to: self.bottomAnchor)
    }
    
    func setup(time: String, price: String, quantity: String, isMarketMaker: Bool) {
        timeTitleLabel.text = time
        priceTitleLabel.text = price
        priceTitleLabel.textColor = isMarketMaker ? .systemGreen : .systemRed
        quantityTitleLabel.text = quantity
    }
    
    private func createTitleLabel(size: CGFloat) -> UILabel {
        return UILabel()
            .font(.systemFont(ofSize: size))
            .textColor(.white)
            .backgroundColor(.clear)
            .numberOfLines(1)
    }
    
}
