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
    func selected(precision: Int)
}

final class TradingCollectionViewHeader: UICollectionReusableView {
    
    private var selections: [Int] = [] {
        didSet {
            selections.enumerated().forEach {
                let button: UIButton = UIButton().title(String($1), for: .normal)
                button.tag = $0
                button.backgroundColor = .black
                button.addTarget(self, action: #selector(precisionSelected), for: .touchUpInside)
                selectionView.addArrangedSubview(button)
            }
        }
    }
    
    private let fontSize: CGFloat = 15
    
    lazy var bidTitleLabel: UILabel = self.createTitleLabel(size: fontSize).text("Bid")
    lazy var askTitleLabel: UILabel = self.createTitleLabel(size: fontSize).text("Ask")
    lazy var percisionBotton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("8", for: .normal)
        button.setImage(UIImage(named: "bottomImage")!, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.backgroundColor = UIColor(red: 35 / 255, green: 40 / 255, blue: 51 / 255, alpha: 1)
        return button
    }()
    
    lazy var selectionView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.isHidden = true
        stackView.backgroundColor = .black
        stackView.isUserInteractionEnabled = true
        return stackView
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setup() {
        addSubview(bidTitleLabel)
        addSubview(askTitleLabel)
        addSubview(percisionBotton)
        addSubview(selectionView)
        
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
        
        percisionBotton.addTarget(self, action: #selector(showSelection), for: .touchUpInside)
        
        selectionView.anchor(\.topAnchor,
                             to: percisionBotton.bottomAnchor)
        selectionView.anchor(\.trailingAnchor,
                             to: self.trailingAnchor,
                             constant: -20)
        selectionView.anchor(\.widthAnchor,
                             to: 80)
    }
    
    func setupBottonSelection(heighestPrecision: Int, currentSelected: Int) {
        var selections: [Int] = []
        for precision in 0...heighestPrecision {
            selections.append(precision)
        }
        self.selections = Array(selections.reversed().prefix(4)).reversed()
        percisionBotton.setTitle(String(currentSelected), for: .normal)
    }
    
    private func createTitleLabel(size: CGFloat) -> UILabel {
        return UILabel()
            .font(.systemFont(ofSize: size))
            .textColor(.systemGray)
            .backgroundColor(.clear)
            .numberOfLines(1)
    }
    
    @objc func showSelection(_ sender: UIButton) {
        selectionView.isHidden.toggle()
    }
    
    @objc func precisionSelected(_ sender: UIButton) {
        delegate?.selected(precision: sender.tag)
    }
    
}
