//
//  WRImageBrowserViewController.swift
//  WRImageBrowser
//
//  Created by 项辉 on 2020/9/28.
//

import UIKit

public class WRImageBrowserViewController: UIViewController {

    // MARK: - Public variables
    /// 数据源
    public weak var dataSource: WRImageBrowserViewControllerDataSource?
    /// 回调
    public weak var delegate: WRImageBrowserViewControllerDelegate?
    /// 浏览方向，默认横向
    public var gestureDirection: BrowserDirection = .horizontal
    /// 浏览样式. 默认 `carousel`.
    public var browserStyle: BrowserStyle = .carousel
    /// 内容变换回调 默认：横向MoveIn
    public var contentTransformer: WRContentTransformerBlock = WRImageContentTransformers.Horizotal.MoveIn {
        didSet {
            WRImageContentView.contentTransformer = contentTransformer
            contentViews.forEach({ $0.updateTransform() })
        }
    }
    /// 绘制优先级. 默认 `previousToNext`.
    public var drawOrder: ContentDrawOrder = .previousToNext {
        didSet {
            if oldValue != drawOrder {
                mediaContainerView.exchangeSubview(at: 0, withSubviewAt: 2)
            }
        }
    }
    public var gapBetweenMediaViews: CGFloat = Constants.gapBetweenContents {
        didSet {
            WRImageContentView.interItemSpacing = gapBetweenMediaViews
            contentViews.forEach({ $0.updateTransform() })
        }
    }

    // MARK: - Internal variables
    lazy internal private(set) var mediaContainerView: UIView = { [unowned self] in
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy private var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        gesture.addTarget(self, action: #selector(panGestureEvent(_:)))
        return gesture
    }()

    // MARK: - Private variables
    private var contentViews: [WRImageContentView] = []
    private var previousTranslation: CGPoint = .zero
    private var distanceToMove: CGFloat = 0.0
    private var timer: Timer?
    private(set) var index: Int = 0
    private var numMediaItems = 0

    public init(
        index: Int = 0,
        dataSource: WRImageBrowserViewControllerDataSource,
        delegate: WRImageBrowserViewControllerDelegate? = nil
        ) {

        self.index = index
        self.dataSource = dataSource
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)

        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        numMediaItems = dataSource?.numberOfItems(in: self) ?? 0

        installContentView()
        
        view.addGestureRecognizer(panGestureRecognizer)
    }
    

}

// MARK: -
fileprivate typealias Public = WRImageBrowserViewController
public extension Public {

}

// MARK: -
fileprivate typealias Private = WRImageBrowserViewController
private extension Private {
    private func initialize() {
        view.backgroundColor = .clear
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    
    private func _contentView(at index: Int) -> WRImageContentView? {

        guard index < contentViews.count else {

            assertionFailure("Content views does not have this many views. : \(index)")
            return nil
        }
        return contentViews[index]
    }

    private func _calculateNormalizedTranslation(translation: CGPoint, viewSize: CGSize) -> CGPoint {

        guard let middleView = _contentView(at: 1) else {
            return .zero
        }

        var normalizedTranslation = CGPoint(
            x: (translation.x)/viewSize.width,
            y: (translation.y)/viewSize.height
        )

        if browserStyle != .carousel || numMediaItems <= 1 {
            let isGestureHorizontal = (gestureDirection == .horizontal)
            let directionalTranslation = isGestureHorizontal ? normalizedTranslation.x : normalizedTranslation.y
            if (middleView.index == 0 && ((middleView.position + directionalTranslation) > 0.0)) ||
                (middleView.index == (numMediaItems - 1) && (middleView.position + directionalTranslation) < 0.0) {
                if isGestureHorizontal {
                    normalizedTranslation.x *= Constants.bounceFactor
                } else {
                    normalizedTranslation.y *= Constants.bounceFactor
                }
            }
        }
        return normalizedTranslation
    }

    private func _moveViews(by translation: CGPoint) {
        let viewSizeIncludingGap = CGSize(
            width: view.frame.size.width + gapBetweenMediaViews,
            height: view.frame.size.height + gapBetweenMediaViews
        )

        let normalizedTranslation = _calculateNormalizedTranslation(translation: translation, viewSize: viewSizeIncludingGap)

        moveViewsNormalized(by: normalizedTranslation)
    }
    
    private func _panGestureRecognizerEnd(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: view)

        var viewsCopy = contentViews
        let previousView = viewsCopy.removeFirst()
        let middleView = viewsCopy.removeFirst()
        let nextView = viewsCopy.removeFirst()

        var toMove: CGFloat = 0.0
        let directionalVelocity = gestureDirection == .horizontal ? velocity.x : velocity.y

        if abs(directionalVelocity) < Constants.minimumVelocity &&
            abs(middleView.position) < Constants.minimumTranslation {
            toMove = -middleView.position
        } else if directionalVelocity < 0.0 {
            if middleView.position >= 0.0 {
                toMove = -middleView.position
            } else {
                toMove = -nextView.position
            }
        } else {
            if middleView.position <= 0.0 {
                toMove = -middleView.position
            } else {
                toMove = -previousView.position
            }
        }
        
        distanceToMove = toMove
        if timer == nil {
            timer = Timer.scheduledTimer(
                timeInterval: 1.0/Double(60),
                target: self,
                selector: #selector(update(_:)),
                userInfo: nil,
                repeats: true
            )
        }

    }
}

// MARK: -
fileprivate typealias Gesture = WRImageBrowserViewController
private extension Gesture {
    @objc private func panGestureEvent(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)

        switch recognizer.state {
        case .began:
            previousTranslation = translation
            distanceToMove = 0.0
            timer?.invalidate()
            timer = nil
        case .changed:
            _moveViews(by: CGPoint(x: translation.x - previousTranslation.x, y: translation.y - previousTranslation.y))
        case .ended, .cancelled, .failed:
            _panGestureRecognizerEnd(recognizer: recognizer)
        default:
            break
        }
        
        previousTranslation = translation
    }
}

// MARK: -
fileprivate typealias UI = WRImageBrowserViewController
private extension UI {
    func installContentView() {
        
        view.addSubview(mediaContainerView)
        NSLayoutConstraint.activate([
            mediaContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mediaContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            mediaContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        for i in -1...1 {
            let imageView = WRImageContentView(index: i, position: CGFloat(i), frame: view.bounds)
            mediaContainerView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: mediaContainerView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: mediaContainerView.trailingAnchor),
                imageView.topAnchor.constraint(equalTo: mediaContainerView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: mediaContainerView.bottomAnchor)
            ])
            contentViews.append(imageView)

        }
    }
    
    @objc private func update(_ timeInterval: TimeInterval) {

        guard distanceToMove != 0.0 else {

            timer?.invalidate()
            timer = nil
            return
        }

        let distance = distanceToMove / (60 * 0.1)
        distanceToMove -= distance
        moveViewsNormalized(by: CGPoint(x: distance, y: distance))

        let translation = CGPoint(
            x: distance * (view.frame.size.width),
            y: distance * (view.frame.size.height)
        )
        let directionalTranslation = translation.x
        if abs(directionalTranslation) < 0.1 {

            moveViewsNormalized(by: CGPoint(x: distanceToMove, y: distanceToMove))
            distanceToMove = 0.0
            timer?.invalidate()
            timer = nil
        }
    }

    private func moveViewsNormalized(by normalizedTranslation: CGPoint) {

        let isGestureHorizontal = true

        contentViews.forEach({
            $0.position += isGestureHorizontal ? normalizedTranslation.x : normalizedTranslation.y
        })

        var viewsCopy = contentViews
        let previousView = viewsCopy.removeFirst()
        let middleView = viewsCopy.removeFirst()
        let nextView = viewsCopy.removeFirst()

        let viewSizeIncludingGap = CGSize(
            width: view.frame.size.width ,
            height: view.frame.size.height
        )

        let viewSize = isGestureHorizontal ? viewSizeIncludingGap.width : viewSizeIncludingGap.height
        let normalizedGap = 0/viewSize
        let normalizedCenter = (middleView.frame.size.width / viewSize) * 0.5
        let viewCount = contentViews.count

        if middleView.position < -(normalizedGap + normalizedCenter) {

            index = sanitizeIndex(index + 1)

            // Previous item is taken and placed on right/down most side
            previousView.position += CGFloat(viewCount)
            previousView.index += viewCount
//            updateContents(of: previousView)

//            if let image = nextView.image {
//                self.visualEffectContentView.image = image
//            }

            contentViews.removeFirst()
            contentViews.append(previousView)

//            switch drawOrder {
//            case .previousToNext:
//                mediaContainerView.bringSubview(toFront: previousView)
//            case .nextToPrevious:
//                mediaContainerView.sendSubview(toBack: previousView)
//            }

//            delegate?.mediaBrowser(self, didChangeFocusTo: index)

        } else if middleView.position > (1 + normalizedGap - normalizedCenter) {

            index = sanitizeIndex(index - 1)

            // Next item is taken and placed on left/top most side
            nextView.position -= CGFloat(viewCount)
            nextView.index -= viewCount
//            updateContents(of: nextView)

//            if let image = previousView.image {
//                self.visualEffectContentView.image = image
//            }

            contentViews.removeLast()
            contentViews.insert(nextView, at: 0)

//            switch drawOrder {
//            case .previousToNext:
//                mediaContainerView.sendSubview(toBack: nextView)
//            case .nextToPrevious:
//                mediaContainerView.bringSubview(toFront: nextView)
//            }
//
//            delegate?.mediaBrowser(self, didChangeFocusTo: index)
        }
    }

    private func sanitizeIndex(_ index: Int) -> Int {
        guard numMediaItems > 0 else {
            return 0
        }
        
        let newIndex = index % numMediaItems
        if newIndex < 0 {
            return newIndex + numMediaItems
        }
        return newIndex
    }

}

// MARK: - UIGestureRecognizerDelegate
fileprivate typealias GestureRecognizerDelegate = WRImageBrowserViewController
extension GestureRecognizerDelegate: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

