//
//  HistoryViewModel.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/16.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import Starscream

protocol HistoryViewModelDelegate: AnyObject {
    func ReceiveNewData()
}

final class HistoryViewModel {
    
    private var socket: WebSocket?
    private let apiString: String = "wss://stream.binance.com:9443/ws/bnbbtc@aggTrade"
    
    weak var delegate: HistoryViewModelDelegate?
    private var pendingStreamModels: [AggregateTradeModel] = []
    private var aggregateTradeModels: [AggregateTradeModel] = []
    
    init() {
        if let url: URL = URL(string: apiString) {
            socket = WebSocket(url: url)
            socket?.delegate = self
            socket?.connect()
        }
        loadSnapshot()
    }
    
    func connet() {
        socket?.connect()
    }
    
    private func loadSnapshot() {
        WebService.shared.getAggregateSnapshot(symbol: "BNBBTC",
                                               limit: 1000,
                                               success: { aggregateTradeModels in
                                                DispatchQueue.main.async {
                                                    self.setupAggregateTradeModel(with: aggregateTradeModels)
                                                }
        },
                                               failure: { error in
                                                
        })
    }
    
    private func setupAggregateTradeModel(with snapshot: [AggregateTradeModel]) {
        aggregateTradeModels = merge(snapshot: snapshot, pendingModels: pendingStreamModels).reversed()
    }
    
    private func merge(snapshot: [AggregateTradeModel], pendingModels: [AggregateTradeModel]) -> [AggregateTradeModel] {
        var models: [AggregateTradeModel] = snapshot
        models.append(contentsOf: pendingModels.filter { $0.tradeTime > (snapshot.first?.tradeTime ?? 0) })
        return models
    }
    
    func numberOfItem() -> Int {
        return min(aggregateTradeModels.count, 14)
    }
    
    func historyModels(by indexPath: IndexPath) -> AggregateTradeModel {
        return aggregateTradeModels[indexPath.item]
    }
    
}

extension HistoryViewModel: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data: Data = text.data(using: .utf8),
            let aggregateTradeStreamModel: AggregateTradeModel = try? JSONDecoder().decode(AggregateTradeModel.self, from: data) {
            if aggregateTradeModels.isEmpty {
                pendingStreamModels.append(aggregateTradeStreamModel)
            } else {
                aggregateTradeModels.insert(aggregateTradeStreamModel, at: 0)
                delegate?.ReceiveNewData()
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
