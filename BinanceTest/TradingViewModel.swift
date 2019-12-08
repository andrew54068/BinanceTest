//
//  TradingViewModel.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import Starscream

protocol TradingViewModelDelegate: AnyObject {
    func Receive(Model: DepthStreamModel)
}

final class TradingViewModel {
    
    private var socket: WebSocket?
    private let apiString: String = "wss://stream.binance.com:9443/ws/bnbbtc@depth"
    
    weak var delegate: TradingViewModelDelegate?
    
    init() {
        if let url: URL = URL(string: "wss://stream.binance.com:9443/ws/bnbbtc@depth") {
            socket = WebSocket(url: url)
            socket?.delegate = self
            socket?.connect()
        }
    }
    
}

extension TradingViewModel: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data: Data = text.data(using: .utf8),
            let jsonObject: Any = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonData: Data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let depthStreamModel: DepthStreamModel = try? JSONDecoder().decode(DepthStreamModel.self, from: jsonData) {
            delegate?.Receive(Model: depthStreamModel)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
