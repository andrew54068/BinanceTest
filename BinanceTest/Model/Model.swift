//
//  Model.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

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
            if let priceLevelToBeUpdated: String = outerArr[safe: 0],
                let quantity: String = outerArr[safe: 1] {
                asksToBeUpdated.append(OfferModel(priceLevelToBeUpdated: priceLevelToBeUpdated,
                                                  quantity: quantity))
            }
        }
        self.asksToBeUpdated = asksToBeUpdated
        
        var singleKeyContainer2: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .asksToBeUpdated)
        var bidsToBeUpdated: [OfferModel] = []
        while !singleKeyContainer2.isAtEnd {
            let outerArr: [String] = try singleKeyContainer2.decode([String].self)
            if let priceLevelToBeUpdated: String = outerArr[safe: 0],
                let quantity: String = outerArr[safe: 1] {
                bidsToBeUpdated.append(OfferModel(priceLevelToBeUpdated: priceLevelToBeUpdated,
                                                  quantity: quantity))
            }
        }
        self.bidsToBeUpdated = bidsToBeUpdated
    }
    
}

struct OfferModel: Codable {
    let priceLevelToBeUpdated: String
    let quantity: String
}
