//
//  WRImageContentView.swift
//  WRImageBrowser
//
//  Created by 项辉 on 2020/9/28.
//

import UIKit

class WRImageContentView: UIScrollView {

    // MARK: Internal variables
    static var interItemSpacing: CGFloat = 0.0
    static var contentTransformer: WRImageContentTransformersProtocol = WRImageContentTransformers.Horizotal.MoveIn

    var position: CGFloat {
        didSet {
            updateTransform()
        }
    }

    var image: UIImage? {
        didSet {
            _updateImageView()
        }
    }

    var index: Int {
        didSet {
            _resetZoom()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
//            indicatorContainer.isHidden = !isLoading
//            if isLoading {
//                indicator.startAnimating()
//            } else {
//                indicator.stopAnimating()
//            }
        }
    }

    var zoomLevels: ZoomScale? {
        didSet {
            zoomScale = ZoomScale.default.minimumZoomScale
            minimumZoomScale = zoomLevels?.minimumZoomScale ?? ZoomScale.default.minimumZoomScale
            maximumZoomScale = zoomLevels?.maximumZoomScale ?? ZoomScale.default.maximumZoomScale
        }
    }

    // MARK:  Private variables

    private lazy var _imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()


    init(index itemIndex: Int, position: CGFloat, frame: CGRect) {
        index = itemIndex
        self.position = position
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        _init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

// MARK: -
fileprivate typealias Internal = WRImageContentView
internal extension Internal {
    func updateTransform() {
        WRImageContentView.contentTransformer.transform(self, position)
    }
}

// MARK: -
fileprivate typealias Private = WRImageContentView
private extension Private {
    func _init() {
        
        addSubview(_imageView)
        _imageView.frame = frame
        
        _configureScrollView()

        updateTransform()
    }
    
    func _configureScrollView() {

        isMultipleTouchEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentSize = _imageView.bounds.size
        canCancelContentTouches = false
        zoomLevels = ZoomScale.default
        delegate = self
        bouncesZoom = false
    }

    func _resetZoom() {

        setZoomScale(1.0, animated: false)
        _imageView.transform = CGAffineTransform.identity
        contentSize = _imageView.frame.size
        contentOffset = .zero
    }

    func _updateImageView() {

        _imageView.image = image

        if let contentImage = image {

            let imageViewSize = bounds.size
            let imageSize = contentImage.size
            var targetImageSize = imageViewSize

            if imageSize.width / imageSize.height > imageViewSize.width / imageViewSize.height {
                targetImageSize.height = imageViewSize.width / imageSize.width * imageSize.height
            } else {
                targetImageSize.width = imageViewSize.height / imageSize.height * imageSize.width
            }

            _imageView.frame = CGRect(origin: .zero, size: targetImageSize)
        }
        _centerImageView()
    }

    func _centerImageView() {

        var imageViewFrame = _imageView.frame

        if imageViewFrame.size.width < bounds.size.width {
            imageViewFrame.origin.x = (bounds.size.width - imageViewFrame.size.width) / 2.0
        } else {
            imageViewFrame.origin.x = 0.0
        }

        if imageViewFrame.size.height < bounds.size.height {
            imageViewFrame.origin.y = (bounds.size.height - imageViewFrame.size.height) / 2.0
        } else {
            imageViewFrame.origin.y = 0.0
        }

        _imageView.frame = imageViewFrame
    }

}

// MARK: - UIScrollViewDelegate
fileprivate typealias ScrollView = WRImageContentView
extension ScrollView: UIScrollViewDelegate {

}
