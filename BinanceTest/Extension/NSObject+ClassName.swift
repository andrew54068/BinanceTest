//
//  NSObject+ClassName.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/8.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import Foundation

public protocol ClassNameProtocol { }

public extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}
