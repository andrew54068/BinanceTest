//
//  TradingPageViewController.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/15.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import DNSPageView

final class TradingPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setup()
    }
    
    private func setup() {
        let style: PageStyle = PageStyle()
        style.titleColor = .white
        style.titleSelectedColor = .systemYellow
        style.titleViewBackgroundColor = .black
        style.isShowBottomLine = true
        style.bottomLineWidth = 40
        style.bottomLineColor = .systemYellow
        style.isTitleViewScrollEnabled = true
        style.isTitleScaleEnabled = false
        style.isContentScrollEnabled = true
        
        let titles: [String] = ["Order Book", "Market History"]
        
        let tradingViewController: TradingViewController = TradingViewController()
        addChild(tradingViewController)
        
        let historyViewController: HistoryViewController = HistoryViewController()
        addChild(historyViewController)
        
        let y: CGFloat = UIApplication.shared.statusBarFrame.height +
            (navigationController?.navigationBar.frame.height ?? 0)
        let size: CGSize = UIScreen.main.bounds.size
        
        let pageView: PageView = PageView(frame: CGRect(x: 0,
                                                        y: y,
                                                        width: size.width,
                                                        height: size.height),
                                          style: style,
                                          titles: titles,
                                          childViewControllers: children)
        view.addSubview(pageView)
    }
    
}
