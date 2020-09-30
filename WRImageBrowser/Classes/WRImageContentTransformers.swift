//
//  WRImageContentTransformers.swift
//  WRImageBrowser
//
//  Created by 项辉 on 2020/9/29.
//

import UIKit

public protocol WRImageContentTransformersProtocol {
    var drawOrder: WRImageBrowserViewController.ContentDrawOrder { get }
    var transform: WRContentTransformerBlock { get }
}

public typealias WRContentTransformerBlock = (_ contentView: UIView, _ position: CGFloat) -> Void


public enum WRImageContentTransformers {
        
    public enum Horizotal {
        case MoveIn
        case SlideIn
    }
}

extension WRImageContentTransformers.Horizotal: WRImageContentTransformersProtocol {
    
    public var transform: WRContentTransformerBlock  {
        switch self {
        case .MoveIn:
            return { contentView, position in
                        let widthIncludingGap = contentView.bounds.width + WRImageContentView.interItemSpacing
                        contentView.transform = CGAffineTransform(translationX: widthIncludingGap * position, y: 0.0)
                    }

        case .SlideIn:
            return { contentView, position in
                var scale: CGFloat = 1.0
                if position > 0.5 {
                    scale = 0.9
                } else if 0.0...0.5 ~= Double(position) {
                    scale = 1.0 - (position * 0.2)
                }
                var transform = CGAffineTransform(scaleX: scale, y: scale)

                let widthIncludingGap = contentView.bounds.size.width + WRImageContentView.interItemSpacing
                let x = position > 0.0 ? 0.0 : widthIncludingGap * position
                transform = transform.translatedBy(x: x, y: 0.0)

                contentView.transform = transform

                let margin: CGFloat = 0.0000001
                contentView.isHidden = ((1.0-margin)...(1.0+margin) ~= abs(position))
            }
        }
    }
    public var drawOrder: WRImageBrowserViewController.ContentDrawOrder {
        switch self {
        case .SlideIn:  return .nextToPrevious
        default:        return .previousToNext
        }
    }

}
