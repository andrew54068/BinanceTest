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
    
    private var socket: WebSocket?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url: URL = URL(string: "wss://stream.binance.com:9443/ws/bnbbtc@depth") {
            socket = WebSocket(url: url)
            socket?.delegate = self
            socket?.connect()
        }
    }
    
}

extension TradingViewController: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
