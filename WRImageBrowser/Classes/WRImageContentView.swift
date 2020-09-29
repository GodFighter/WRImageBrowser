//
//  WRImageContentView.swift
//  WRImageBrowser
//
//  Created by 项辉 on 2020/9/28.
//

import UIKit

class WRImageContentView: UIScrollView {

    // MARK: - Internal variables
    internal static var interItemSpacing: CGFloat = 0.0
    internal static var contentTransformer: WRContentTransformerBlock = WRImageContentTransformers.Horizotal.MoveIn

    var index: Int
    var position: CGFloat {
        didSet {
            updateTransform()
        }
    }
    

    init(index itemIndex: Int, position: CGFloat, frame: CGRect) {
        index = itemIndex
        self.position = position
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor.init(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
        
        _init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


fileprivate typealias Internal = WRImageContentView
internal extension Internal {
    func updateTransform() {
        WRImageContentView.contentTransformer(self, position)
    }
}

fileprivate typealias Private = WRImageContentView
internal extension Private {
    func _init() {
        
        updateTransform()
    }
}
