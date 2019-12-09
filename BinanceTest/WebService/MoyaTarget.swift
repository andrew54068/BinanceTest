//
//  MoyaTarget.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/9.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import Moya

enum BinanceApi: TargetType {
    case depthSnapshot(symbol: String, limit: Int)
}

extension BinanceApi {
    
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "https://www.binance.com/")!
    }
    
    var path: String {
        return "api/v1/depth"
    }
    
    var method: Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case let .depthSnapshot(symbol, limit):
            return .requestParameters(parameters: ["symbol": symbol,
                                                   "limit": String(limit)],
                                      encoding: URLEncoding.default)
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
}
