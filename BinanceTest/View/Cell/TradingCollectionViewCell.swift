//
//  TradingCollectionViewCell.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import RainKit

enum TradingType {
    case bid
    case ask
}

final class TradingCollectionViewCell: UICollectionViewCell {
    
    lazy var type: TradingType = .bid
    
    private let fontSize: CGFloat = 15
    
    lazy var bidQuantityLabel: UILabel = self.createQuantityLabel(size: fontSize)
    lazy var bidPriceLabel: UILabel = self.createPriceLabel(type: .bid, size: fontSize)
    lazy var askQuantityLabel: UILabel = self.createQuantityLabel(size: fontSize)
    lazy var askPriceLabel: UILabel = self.createPriceLabel(type: .ask, size: fontSize)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(bidModel: OfferModel?, askModel: OfferModel?) {
        setupViews()
        bidQuantityLabel.text = bidModel?.quantity
        bidPriceLabel.text = bidModel?.priceLevelToBeUpdated
        askPriceLabel.text = askModel?.priceLevelToBeUpdated
        askQuantityLabel.text = askModel?.quantity
    }
    
    private func setupViews() {
        contentView.addSubview(bidQuantityLabel)
        contentView.addSubview(bidPriceLabel)
        contentView.addSubview(askQuantityLabel)
        contentView.addSubview(askPriceLabel)
        
        bidQuantityLabel.anchor(\.leadingAnchor,
                                to: contentView.leadingAnchor)
        bidQuantityLabel.anchor(\.topAnchor,
                                to: contentView.topAnchor)
        bidQuantityLabel.anchor(\.bottomAnchor,
                                to: contentView.bottomAnchor)
        
        bidPriceLabel.anchor(\.trailingAnchor,
                             to: contentView.centerXAnchor)
        bidPriceLabel.anchor(\.topAnchor,
                             to: contentView.topAnchor)
        bidPriceLabel.anchor(\.bottomAnchor,
                             to: contentView.bottomAnchor)
        
        askPriceLabel.anchor(\.leadingAnchor,
                             to: contentView.centerXAnchor)
        askPriceLabel.anchor(\.topAnchor,
                             to: contentView.topAnchor)
        askPriceLabel.anchor(\.bottomAnchor,
                             to: contentView.bottomAnchor)
        
        askQuantityLabel.anchor(\.trailingAnchor,
                                to: contentView.trailingAnchor)
        askQuantityLabel.anchor(\.topAnchor,
                                to: contentView.topAnchor)
        askQuantityLabel.anchor(\.bottomAnchor,
                                to: contentView.bottomAnchor)
    }
    
    private func createPriceLabel(type: TradingType, size: CGFloat) -> UILabel {
        return UILabel()
            .font(.systemFont(ofSize: size))
            .textColor(type == .bid ? .systemGreen : .systemRed)
            .numberOfLines(1)
    }
    
    private func createQuantityLabel(size: CGFloat) -> UILabel {
        return UILabel()
            .font(.systemFont(ofSize: size))
            .textColor(.white)
            .numberOfLines(1)
    }
    
}
