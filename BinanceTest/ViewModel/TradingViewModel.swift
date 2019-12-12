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
    private var streamModels: [DepthStreamModel] = []
    
    private var mergedModel: (asks: [OfferModel], bids: [OfferModel]) = ([], [])
    
    private var askOfferPool: [String: String] = [:]
    private var bidOfferPool: [String: String] = [:]
    
    init() {
        if let url: URL = URL(string: apiString) {
            socket = WebSocket(url: url)
            socket?.delegate = self
            socket?.connect()
        }
        loadSnapshot()
    }
    
    private func loadSnapshot() {
        WebService.shared.getTradeDepthSnapshot(target: BinanceApi.depthSnapshot(symbol: "BNBBTC", limit: 1000),
                                                success: { depthSnapshotModel in
                                                    DispatchQueue.main.async {
                                                        self.setupMergedModel(with: depthSnapshotModel)
                                                    }
            },
                                                failure: { error in
                                                    
        })
    }
    
    private func setupMergedModel(with snapshot: DepthSnapshotModel) {
        snapshot.asks.forEach {
            askOfferPool[$0.price] = $0.quantity
        }
        snapshot.bids.forEach {
            bidOfferPool[$0.price] = $0.quantity
        }
        let validStreamModels: [DepthStreamModel] = streamModels.filter({ $0.finalUpdateIdInEvent > snapshot.lastUpdateId })
        validStreamModels.forEach({ updatePool(with: $0) })
        mergedModel = getOfferTuple(by: 8)
    }
    
    private func updatePool(with streamModel: DepthStreamModel) {
        streamModel.asksToBeUpdated.forEach { offerModel in
            askOfferPool[offerModel.price] = offerModel.quantity
        }
        streamModel.bidsToBeUpdated.forEach { offerModel in
            bidOfferPool[offerModel.price] = offerModel.quantity
        }
    }
    
    private func getOfferTuple(by precisionDigit: Int) -> (asks: [OfferModel], bids: [OfferModel]) {
        let askGrouping: [String: Array<(key: String, value: String)>] = grouping(pool: askOfferPool,
                                                                                  by: precisionDigit)
        let asks: [OfferModel] = askGrouping.map({ OfferModel(price: $0.key,
                                                              quantity: String($0.value.reduce(0) { $0 + (Double($1.value) ?? 0) })) })
        
        let bidGrouping: [String: Array<(key: String, value: String)>] = grouping(pool: bidOfferPool,
                                                                                  by: precisionDigit)
        let bids: [OfferModel] = bidGrouping.map({ OfferModel(price: $0.key,
                                                              quantity: String($0.value.reduce(0) { $0 + (Double($1.value) ?? 0) })) })
        
        mergedModel = (asks.sorted(by: <), bids.sorted(by: >))
        return mergedModel
    }
    
    private func grouping(pool: [String: String], by precisionDigit: Int) -> [String: Array<(key: String, value: String)>] {
        let scaleFactor: Double = pow(10, Double(precisionDigit))
        return Dictionary(grouping: pool) { element -> String in
            if let double: Double = Double(element.key.trimmingCharacters(in: .whitespaces)) {
                return String(ceil(double * scaleFactor) / scaleFactor)
            } else {
                return "error"
            }
        }
    }

    func numberOfItem() -> Int {
        return min(max(mergedModel.bids.count, mergedModel.asks.count), 14)
    }
    
    func offerModels(by indexPath: IndexPath) -> (ask: OfferModel?, bid: OfferModel?) {
        return (mergedModel.asks[safe: indexPath.item], mergedModel.bids[safe: indexPath.item])
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
            DispatchQueue.main.async {
                if self.mergedModel.asks.count + self.mergedModel.bids.count == 0 {
                    self.streamModels.append(depthStreamModel)
                } else {
                    self.updatePool(with: depthStreamModel)
                    self.delegate?.ReceiveNewData()
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
