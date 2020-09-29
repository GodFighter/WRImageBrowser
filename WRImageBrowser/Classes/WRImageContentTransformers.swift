//
//  WRImageContentTransformers.swift
//  WRImageBrowser
//
//  Created by 项辉 on 2020/9/29.
//

import UIKit

public typealias WRContentTransformerBlock = (_ contentView: UIView, _ position: CGFloat) -> Void

public enum WRImageContentTransformers {
    
    public enum Horizotal {
        public static let MoveIn: WRContentTransformerBlock = { contentView, position in
            let widthIncludingGap = contentView.bounds.width + WRImageContentView.interItemSpacing
            contentView.transform = CGAffineTransform(translationX: widthIncludingGap * position, y: 0.0)
        }
    }
}
