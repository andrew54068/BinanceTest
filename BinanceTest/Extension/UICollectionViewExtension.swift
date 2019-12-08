//
//  UICollectionViewExtension.swift
//  BinanceTest
//
//  Created by kidnapper on 2019/12/9.
//  Copyright © 2019 kidnapper. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func dequeueReusableCell<Type: UICollectionViewCell>(with type: Type.Type, indexPath: IndexPath) -> Type {
        let id: String = type.className
        register(type.self,
                 forCellWithReuseIdentifier: id)
        return dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! Type
    }
    
    func dequeueReusableHeaderCell<Type: UICollectionReusableView>(with type: Type.Type, indexPath: IndexPath) -> Type {
        let id: String = type.className
        let kind: String = UICollectionView.elementKindSectionHeader
        register(type.self,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: id)
        return dequeueReusableSupplementaryView(ofKind: kind,
                                                withReuseIdentifier: id,
                                                for: indexPath) as! Type
    }
    
    func dequeueReusableFooterCell<Type: UICollectionReusableView>(with type: Type.Type, indexPath: IndexPath) -> Type {
        let id: String = type.className
        let kind: String = UICollectionView.elementKindSectionFooter
        register(type.self,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: id)
        return dequeueReusableSupplementaryView(ofKind: kind,
                                                withReuseIdentifier: id,
                                                for: indexPath) as! Type
    }
    
}

