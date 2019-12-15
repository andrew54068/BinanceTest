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
    
    private var mergedModel: (bids: [OfferModel], asks: [OfferModel]) = ([], [])
    
    private var askOfferPool: [String: String] = [:]
    private var bidOfferPool: [String: String] = [:]
    
    var precisionDigit: Int = 8
    var precisionDigitSelected: Int = 8
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = precisionDigit
        formatter.minimumFractionDigits = precisionDigit
        return formatter
    }()
    
    private lazy var quantityFormatter: NumberFormatter = {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
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
        snapshot.bids.forEach {
            bidOfferPool[$0.price] = $0.quantity
        }
        snapshot.asks.forEach {
            askOfferPool[$0.price] = $0.quantity
        }
        let validStreamModels: [DepthStreamModel] = streamModels.filter({ $0.finalUpdateIdInEvent > snapshot.lastUpdateId })
        validStreamModels.forEach({ updatePool(with: $0) })
        mergedModel = getOfferTuple(by: precisionDigit)
    }
    
    private func updatePool(with streamModel: DepthStreamModel) {
        streamModel.bidsToBeUpdated.forEach { offerModel in
            bidOfferPool[offerModel.price] = offerModel.quantity
        }
        streamModel.asksToBeUpdated.forEach { offerModel in
            askOfferPool[offerModel.price] = offerModel.quantity
        }
    }
    
    private func getOfferTuple(by precisionDigit: Int) -> (bids: [OfferModel], asks: [OfferModel]) {
        let bidGrouping: [String: Array<(key: String, value: String)>] = grouping(pool: bidOfferPool,
                                                                                  by: precisionDigit,
                                                                                  roundStrategy: floor)
        let bids: [OfferModel] = transformToModels(from: bidGrouping, formatter: quantityFormatter)
        
        let askGrouping: [String: Array<(key: String, value: String)>] = grouping(pool: askOfferPool,
                                                                                  by: precisionDigit,
                                                                                  roundStrategy: ceil)
        let asks: [OfferModel] = transformToModels(from: askGrouping, formatter: quantityFormatter)
        
        mergedModel = (bids.sorted(by: >), asks.sorted(by: <))
        return mergedModel
    }
    
    private func grouping(pool: [String: String], by precisionDigit: Int, roundStrategy: ((_: Double) -> Double)) -> [String: Array<(key: String, value: String)>] {
        let scaleFactor: Double = pow(10, Double(precisionDigit))
        var result = Dictionary(grouping: pool) { element -> String in
            if Double(element.value.trimmingCharacters(in: .whitespaces)) == 0 {
                return "0"
            } else if let double: Double = Double(element.key.trimmingCharacters(in: .whitespaces)) {
                let roundedResult: Decimal = Decimal(roundStrategy(double * scaleFactor)) / Decimal(scaleFactor)
                if let formattedString: String = priceFormatter.string(from: roundedResult as NSDecimalNumber) {
                    return formattedString
                } else {
                    return "error"
                }
            } else {
                return "error"
            }
        }
        result.removeValue(forKey: "0")
        result.removeValue(forKey: "error")
        return result
    }
    
    private func transformToModels(from grouping: [String: Array<(key: String, value: String)>], formatter: NumberFormatter) -> [OfferModel] {
        return grouping.compactMap({
            if let quantity: String = formatter.string(from: NSNumber(value: $0.value.reduce(0) { $0 + (Double($1.value) ?? 0) })) {
                return OfferModel(price: $0.key,
                                  quantity: quantity)
            } else {
                return nil
            }
        })
    }
    
    func numberOfItem() -> Int {
        return min(max(mergedModel.bids.count, mergedModel.asks.count), 14)
    }
    
    func offerModels(by indexPath: IndexPath) -> (bid: OfferModel?, ask: OfferModel?) {
        mergedModel = getOfferTuple(by: precisionDigit)
        return (mergedModel.bids[safe: indexPath.item], mergedModel.asks[safe: indexPath.item])
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
