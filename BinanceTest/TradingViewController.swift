//
//  TradingViewController.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit
import Starscream

final class TradingViewController: UIViewController {
    
    lazy var viewModel: TradingViewModel = TradingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }
    
}

extension TradingViewController: TradingViewModelDelegate {
    
    func Receive(Model: DepthStreamModel) {
        
    }
    
}
