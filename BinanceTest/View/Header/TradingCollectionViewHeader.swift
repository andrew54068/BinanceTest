//
//  TradingCollectionViewHeader.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/15.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import RainKit

protocol TradingCollectionViewHeaderDelegate: AnyObject {
    func precisionOptionDisplay()
}

final class TradingCollectionViewHeader: UICollectionReusableView {
    
    private let fontSize: CGFloat = 15
    
    lazy var bidTitleLabel: UILabel = self.createTitleLabel(size: fontSize).text("Bid")
    lazy var askTitleLabel: UILabel = self.createTitleLabel(size: fontSize).text("Ask")
    
    lazy var percisionBotton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("8", for: .normal)
        button.setImage(UIImage(named: "bottomImage")!, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.backgroundColor = UIColor(red: 35 / 255, green: 40 / 255, blue: 51 / 255, alpha: 1)
        button.addTarget(self, action: #selector(showSelection), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: TradingCollectionViewHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(bidTitleLabel)
        addSubview(askTitleLabel)
        addSubview(percisionBotton)
        
        bidTitleLabel.anchor(\.leadingAnchor,
                             to: self.leadingAnchor,
                             constant: 5)
        bidTitleLabel.anchor(\.topAnchor,
                             to: self.topAnchor)
        bidTitleLabel.anchor(\.bottomAnchor,
                             to: self.bottomAnchor)
        
        askTitleLabel.anchor(\.leadingAnchor,
                             to: self.centerXAnchor,
                             constant: 5)
        askTitleLabel.anchor(\.topAnchor,
                             to: self.topAnchor)
        askTitleLabel.anchor(\.bottomAnchor,
                             to: self.bottomAnchor)
        
        percisionBotton.anchor(\.topAnchor,
                               to: self.topAnchor)
        percisionBotton.anchor(\.bottomAnchor,
                               to: self.bottomAnchor)
        percisionBotton.anchor(\.trailingAnchor,
                               to: self.trailingAnchor,
                               constant: -15)
        
        percisionBotton.anchor(\.widthAnchor, to: 70)
    }
    
    private func createTitleLabel(size: CGFloat) -> UILabel {
        return UILabel()
            .font(.systemFont(ofSize: size))
            .textColor(.systemGray)
            .backgroundColor(.clear)
            .numberOfLines(1)
    }
    
    func setupBottonSelection(currentSelected: Int) {
        percisionBotton.setTitle(String(currentSelected), for: .normal)
    }
    
    @objc func showSelection(_ sender: UIButton) {
        delegate?.precisionOptionDisplay()
    }
    
}

