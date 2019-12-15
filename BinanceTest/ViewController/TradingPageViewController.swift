//
//  TradingPageViewController.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/15.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import DNSPageView
import Reachability

final class TradingPageViewController: UIViewController {
    
    var tradingViewController: TradingViewController?
    var historyViewController: HistoryViewController?
    
    lazy var reachability = try! Reachability()
    
    lazy var networkUnreachableBanner: UILabel = {
        let view: UILabel = UILabel()
        view.text = "Network Unreachable"
        view.textColor = .white
        view.backgroundColor = .systemRed
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        view.backgroundColor = .black
        setupViews()
        setupNetworkUnreachableBanner()
        
        reachability.whenReachable = { reachability in
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.networkUnreachableBanner.transform = CGAffineTransform(translationX: 0, y: -100)
            }, completion: { _ in
                self.tradingViewController?.connet()
                self.historyViewController?.connet()
            })
        }
        
        reachability.whenUnreachable = { _ in
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.networkUnreachableBanner.transform = CGAffineTransform.identity
            }, completion: nil)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func setupNavigationBar() {
        title = "Binance"
        extendedLayoutIncludesOpaqueBars = true
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupViews() {
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
        
        let tradingVC: TradingViewController = TradingViewController()
        tradingViewController = tradingVC
        addChild(tradingVC)
        
        let historyVC: HistoryViewController = HistoryViewController()
        historyViewController = historyVC
        addChild(historyVC)
        
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
    
    private func setupNetworkUnreachableBanner() {
        view.addSubview(networkUnreachableBanner)
        networkUnreachableBanner.anchor(\.topAnchor, to: view.safeAreaLayoutGuide.topAnchor)
            .anchor(\.leadingAnchor, to: view.leadingAnchor)
            .anchor(\.trailingAnchor, to: view.trailingAnchor)
            .anchor(\.heightAnchor, to: 30)
        networkUnreachableBanner.transform = CGAffineTransform(translationX: 0, y: -100)
    }
    
}
