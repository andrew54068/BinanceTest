//
//  WebService.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/9.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import Moya
import Alamofire

extension MoyaProvider {

    final class var `default`: MoyaProvider {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let manager: SessionManager = Alamofire.SessionManager(configuration: configuration)
        manager.startRequestsImmediately = false
        return MoyaProvider<Target>(callbackQueue: .global(), manager: manager)
    }
    
}

final class WebService: NSObject {
    
    typealias ModelSuccessClosure<T: Codable> = (T) -> Void
    typealias ErrorClosure = (MoyaError) -> Void

    static let shared: WebService = WebService()
    
    @discardableResult
    func request<Model, Target>(provider: MoyaProvider<Target> = MoyaProvider<Target>.default,
                                target: Target,
                                decoder: JSONDecoder = JSONDecoder(),
                                success: ModelSuccessClosure<Model>?,
                                failure: ErrorClosure?) -> Cancellable where Model: Codable {
        
        return provider.request(target) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    let model: Model = try decoder.decode(Model.self, from: moyaResponse.data)
                    success?(model)
                } catch {
                    failure?(MoyaError.objectMapping(error, moyaResponse))
                }
            case let .failure(error):
                failure?(error)
            }
        }
    }

}

extension WebService {
    
    func getTradeDepthSnapshot(provider: MoyaProvider<BinanceApi> = .default,
                               target: BinanceApi,
                               success: ModelSuccessClosure<DepthSnapshotModel>?,
                               failure: ErrorClosure?) {
        
        request(target: target,
                success: success,
                failure: failure)
    }
    
}
