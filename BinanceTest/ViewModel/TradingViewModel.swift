//
//  TradingViewModel.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import Starscream

protocol TradingViewModelDelegate: AnyObject {
    func ReceiveNewData()
}

final class TradingViewModel {
    
    private var socket: WebSocket?
    private let apiString: String = "wss://stream.binance.com:9443/ws/bnbbtc@depth"
    
    weak var delegate: TradingViewModelDelegate?
    private var model: DepthStreamModel?
    
    init() {
        if let url: URL = URL(string: apiString) {
            socket = WebSocket(url: url)
            socket?.delegate = self
            socket?.connect()
        }
    }
    
    func numberOfItem() -> Int {
        guard let model: DepthStreamModel = model else { return 0 }
        return max(model.bidsToBeUpdated.count,
                   model.asksToBeUpdated.count)
    }
    
    func offerModels(by indexPath: IndexPath) -> (bid: OfferModel?, ask: OfferModel?) {
        return (model?.bidsToBeUpdated[safe: indexPath.item],
                model?.asksToBeUpdated[safe: indexPath.item])
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
            model = depthStreamModel
            delegate?.ReceiveNewData()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
