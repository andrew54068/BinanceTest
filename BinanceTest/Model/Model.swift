//
//  Model.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import Foundation

/*
 {
   "E": 1575813395670,      // Event time
   "U": 518981673,          // First update ID in event
   "a": [                   // Asks to be updated
     [
       "0.00500000",        // Price level to be updated
       "14651.83000000"     // Quantity
     ]
   ],
   "b": [                   // Bids to be updated
     [
       "0.00207270",        // Price level to be updated
       "11.00000000"        // Quantity
     ]
   ],
   "e": "depthUpdate",      // Event type
   "s": "BNBBTC",           // Symbol
   "u": 518981675           // Final update ID in event
 }
 */

struct DepthStreamModel: Codable {
    let eventTime, firstUpdateIdInEvent, finalUpdateIdInEvent: Int
    let eventType, symbol: String
    let asksToBeUpdated: [OfferModel]
    let bidsToBeUpdated: [OfferModel]
    
    enum CodingKeys: String, CodingKey {
        case eventTime = "E"
        case asksToBeUpdated = "a"
        case bidsToBeUpdated = "b"
        case eventType = "e"
        case symbol = "s"
        case firstUpdateIdInEvent = "U"
        case finalUpdateIdInEvent = "u"
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
        eventTime = try container.decode(Int.self, forKey: .eventTime)
        firstUpdateIdInEvent = try container.decode(Int.self, forKey: .firstUpdateIdInEvent)
        finalUpdateIdInEvent = try container.decode(Int.self, forKey: .finalUpdateIdInEvent)
        eventType = try container.decode(String.self, forKey: .eventType)
        symbol = try container.decode(String.self, forKey: .symbol)
        
        var singleKeyContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .asksToBeUpdated)
        var asksToBeUpdated: [OfferModel] = []
        while !singleKeyContainer.isAtEnd {
            let outerArr: [String] = try singleKeyContainer.decode([String].self)
            if let price: String = outerArr[safe: 0],
                let quantity: String = outerArr[safe: 1] {
                asksToBeUpdated.append(OfferModel(price: price,
                                                  quantity: quantity))
            }
        }
        self.asksToBeUpdated = asksToBeUpdated
        
        var singleKeyContainer2: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .bidsToBeUpdated)
        var bidsToBeUpdated: [OfferModel] = []
        while !singleKeyContainer2.isAtEnd {
            let outerArr: [String] = try singleKeyContainer2.decode([String].self)
            if let price: String = outerArr[safe: 0],
                let quantity: String = outerArr[safe: 1] {
                bidsToBeUpdated.append(OfferModel(price: price,
                                                  quantity: quantity))
            }
        }
        self.bidsToBeUpdated = bidsToBeUpdated
    }
    
}

struct OfferModel: Codable, Comparable {
    static func < (lhs: OfferModel, rhs: OfferModel) -> Bool {
        guard let l: Double = Double(lhs.price.trimmingCharacters(in: .whitespaces)),
            let r: Double = Double(rhs.price.trimmingCharacters(in: .whitespaces)) else { return false }
        return l < r
    }
    
    var price: String
    var quantity: String
}

/*
 {
    lastUpdateId: 519067757,
        bids: [
        [
         "0.00208390",
         "14.46000000"
        ],
        asks: [
        [
         "0.00208440",
         "74.59000000"
        ]
     ]
 }
 */

struct DepthSnapshotModel: Codable {
    let lastUpdateId: Int
    let bids: [OfferModel]
    let asks: [OfferModel]
    
    enum CodingKeys: String, CodingKey {
        case lastUpdateId
        case bids
        case asks
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
        lastUpdateId = try container.decode(Int.self, forKey: .lastUpdateId)
        
        var singleKeyContainer1: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .bids)
        var bids: [OfferModel] = []
        while !singleKeyContainer1.isAtEnd {
            let outerArr: [String] = try singleKeyContainer1.decode([String].self)
            if let price: String = outerArr[safe: 0],
                let quantity: String = outerArr[safe: 1] {
                bids.append(OfferModel(price: price,
                                       quantity: quantity))
            }
        }
        self.bids = bids
        
        var singleKeyContainer2: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .asks)
        var asks: [OfferModel] = []
        while !singleKeyContainer2.isAtEnd {
            let outerArr: [String] = try singleKeyContainer2.decode([String].self)
            if let price: String = outerArr[safe: 0],
                let quantity: String = outerArr[safe: 1] {
                asks.append(OfferModel(price: price,
                                       quantity: quantity))
            }
        }
        self.asks = asks
    }
    
}

/*
 {
   "e": "aggTrade",  // Event type
   "E": 123456789,   // Event time
   "s": "BNBBTC",    // Symbol
   "a": 12345,       // Aggregate trade ID
   "p": "0.001",     // Price
   "q": "100",       // Quantity
   "f": 100,         // First trade ID
   "l": 105,         // Last trade ID
   "T": 123456785,   // Trade time
   "m": true,        // Is the buyer the market maker?
   "M": true         // Ignore
 }
 */

struct AggregateTradeModel: Codable {
    let tradeId: Int
    let price: String
    let quantity: String
    let firstTradeId: Int
    let LastTradeId: Int
    let tradeTime: TimeInterval
    let isMarketMaker: Bool
    
    enum CodingKeys: String, CodingKey {
        case tradeId  = "a"
        case price  = "p"
        case quantity  = "q"
        case firstTradeId  = "f"
        case LastTradeId  = "l"
        case tradeTime  = "T"
        case isMarketMaker  = "m"
    }
    
    func getTradeTime() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: Double(tradeTime)))
    }
    
}
