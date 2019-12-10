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
    private var combinedModel: (asks: [OfferModel], bids: [OfferModel])?
    private var bidPriceDic: [String: String] = [:]
    private var askPriceDic: [String: String] = [:]
    
    init() {
        if let url: URL = URL(string: apiString) {
            socket = WebSocket(url: url)
            socket?.delegate = self
            socket?.connect()
        }
        loadSnapshot()
    }
    
    private func loadSnapshot() {
        WebService.shared.getTradeDepthSnapshot(target: BinanceApi.depthSnapshot(symbol: "BNBBTC", limit: 100),
                                                success: { depthSnapshotModel in
                                                    DispatchQueue.main.async {
                                                        self.setupCombinedModel(with: depthSnapshotModel)
                                                    }
            },
                                                failure: { error in
                                                    
        })
    }
    
    private func setupCombinedModel(with snapshot: DepthSnapshotModel) {
        combinedModel = (snapshot.asks, snapshot.bids)
        let validStreamModels: [DepthStreamModel] = streamModels.filter({ $0.finalUpdateIdInEvent > snapshot.lastUpdateId })
        validStreamModels.forEach({
            mergeModel(combinedModel: (snapshot.asks, snapshot.bids), streamModel: $0)
        })
    }
    
    private func updateCombinedModel(with streamModel: DepthStreamModel) {
        guard let combinedModel = combinedModel else { return }
        mergeModel(combinedModel: combinedModel, streamModel: streamModel)
    }
    
    private func mergeModel(combinedModel: (asks: [OfferModel], bids: [OfferModel]), streamModel: DepthStreamModel) {
        var tempCombinedModel = combinedModel
        streamModel.asksToBeUpdated.forEach { offerModel in
            var contains: Bool = false
            for (index, ask) in tempCombinedModel.asks.enumerated() where ask.price == offerModel.price {
                tempCombinedModel.asks[index] = offerModel
                contains = true
            }
            if contains == false {
                tempCombinedModel.asks.append(offerModel)
                tempCombinedModel.asks.sort(by: <)
            }
        }
        tempCombinedModel.asks.removeAll(where: { offerModel -> Bool in
            guard let quantity: Double = Double(offerModel.quantity.trimmingCharacters(in: .whitespaces)) else { return true }
            return quantity == 0
        })
        streamModel.bidsToBeUpdated.forEach { offerModel in
            var contains: Bool = false
            for (index, bid) in tempCombinedModel.bids.enumerated() where bid.price == offerModel.price {
                tempCombinedModel.bids[index] = offerModel
                contains = true
            }
            if contains == false {
                tempCombinedModel.bids.append(offerModel)
                tempCombinedModel.bids.sort(by: >)
            }
        }
        tempCombinedModel.bids.removeAll(where: { offerModel -> Bool in
            guard let quantity: Double = Double(offerModel.quantity.trimmingCharacters(in: .whitespaces)) else { return true }
            return quantity == 0
        })
        self.combinedModel = tempCombinedModel
    }

    func numberOfItem() -> Int {
        guard let model: (asks: [OfferModel], bids: [OfferModel]) = combinedModel else { return 0 }
        return min(max(model.bids.count, model.asks.count), 14)
    }
    
    func offerModels(by indexPath: IndexPath) -> (bid: OfferModel?, ask: OfferModel?) {
        return (combinedModel?.bids[safe: indexPath.item],
                combinedModel?.asks[safe: indexPath.item])
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
                if self.combinedModel == nil {
                    self.streamModels.append(depthStreamModel)
                } else {
                    self.updateCombinedModel(with: depthStreamModel)
                    self.delegate?.ReceiveNewData()
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
}
