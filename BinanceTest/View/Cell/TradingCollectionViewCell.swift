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
    private var precisionOrder: Int = 4
    
    private var backgroundLayers: [CALayer] = []
    
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
    
    func update(bidModel: OfferModel?, askModel: OfferModel?, precisionOrder: Int) {
        addLayers(bidQuantity: bidModel?.quantity ?? "0",
                  askQuantity: askModel?.quantity ?? "0")
        setupViews()
        self.precisionOrder = precisionOrder
        bidQuantityLabel.text = bidModel?.quantity
        bidPriceLabel.text = bidModel?.price
        askPriceLabel.text = askModel?.price
        askQuantityLabel.text = askModel?.quantity
    }
    
    private func setupViews() {
        contentView.addSubview(bidQuantityLabel)
        contentView.addSubview(bidPriceLabel)
        contentView.addSubview(askQuantityLabel)
        contentView.addSubview(askPriceLabel)
        
        bidQuantityLabel.anchor(\.leadingAnchor,
                                to: contentView.leadingAnchor,
                                constant: 5)
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
                             to: contentView.centerXAnchor,
                             constant: 5)
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
    
    private func addLayers(bidQuantity: String, askQuantity: String) {
        let maxValue: CGFloat
        switch precisionOrder {
        case 1:
            maxValue = 2000
        case 2:
            maxValue = 1500
        case 3:
            maxValue = 300
        case 4:
            maxValue = 70
        default:
            maxValue = 1000
        }
        backgroundLayers = [addLayerIfNeeded(quantity: bidQuantity,
                                             type: .bid,
                                             maxValue: maxValue,
                                             color: UIColor.systemGreen.withAlphaComponent(0.3))]
        
        backgroundLayers.append(addLayerIfNeeded(quantity: askQuantity,
                                                 type: .ask,
                                                 maxValue: maxValue,
                                                 color: UIColor.systemRed.withAlphaComponent(0.3)))
    }
    
    private func addLayerIfNeeded(quantity: String, type: TradingType, maxValue: CGFloat, color: UIColor) -> CALayer {
        let halfWidth: CGFloat = bounds.width / 2
        if let value: Double = Double(quantity) {
            let widthPortion: CGFloat = CGFloat(value) / maxValue * halfWidth
            let backgroundLayer: CALayer = CALayer()
            let x: CGFloat = type == .bid ? halfWidth - widthPortion : halfWidth
            backgroundLayer.frame = CGRect(x: x,
                                           y: 0,
                                           width: widthPortion,
                                           height: bounds.height)
            backgroundLayer.backgroundColor = color.cgColor
            layer.addSublayer(backgroundLayer)
            return backgroundLayer
        }
        return CALayer()
    }
    
    private func createPriceLabel(type: TradingType, size: CGFloat) -> UILabel {
        return UILabel()
            .font(.systemFont(ofSize: size))
            .textColor(type == .bid ? .systemGreen : .systemRed)
            .backgroundColor(.clear)
            .numberOfLines(1)
    }
    
    private func createQuantityLabel(size: CGFloat) -> UILabel {
        return UILabel()
            .font(.systemFont(ofSize: size))
            .backgroundColor(.clear)
            .textColor(.white)
            .numberOfLines(1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundLayers.forEach { $0.removeFromSuperlayer() }
    }
    
}
