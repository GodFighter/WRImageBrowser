//
//  WRImageBrowserDefine.swift
//  WRImageBrowser
//
//  Created by 项辉 on 2020/9/29.
//

import UIKit

// MARK:- Define
fileprivate typealias Define = WRImageBrowserViewController
extension Define {
    
    /**
     浏览方向枚举.

     ```
     case horizontal
     case vertical
     ```
    */
    public enum BrowserDirection {

        /// 左右浏览.
        case horizontal
        /// 上下浏览.
        case vertical
    }

    /**
     支持的浏览样式枚举.

     ```
     case linear
     case carousel
     ```
     */
    public enum BrowserStyle {

        /// 线性浏览，有头有尾.
        case linear
        /// 轮训浏览，无头无尾.
        case carousel
    }

    /**
     绘制方向枚举.

     ```
     case previousToNext
     case nextToPrevious
     ```
     - note:
        这是绘制的顺序，而不是绘制的位置，他决定了谁绘制在上层，谁绘制在下层.
     */
    public enum ContentDrawOrder {

        /// 绘制顺序为 [previous]-[current]-[next].
        case previousToNext
        /// 绘制顺序为 [next]-[current]-[previous] .
        case nextToPrevious
    }

}

// MARK:- WRImageBrowserViewControllerDataSource
public protocol WRImageBrowserViewControllerDataSource: class {

    /**
     完成回调.
     
     <必选>
     
     - parameter index: 图片索引.
     - parameter image: 需要展示的图片.
     - parameter zoomScale: 图片可缩放的级别.
     - parameter error: 收到图片后的错误.
     */
    typealias CompletionBlock = (_ index: Int, _ image: UIImage?, _ zoomScale: ZoomScale?, _ error: Error?) -> Void

    /**
     浏览器中展示的项目个数委托.
     - parameter imageBrowser: 图片浏览器.
     - returns: 展示的个数.
     */
    func numberOfItems(in imageBrowser: WRImageBrowserViewController) -> Int

    /**
     指定索引的图片配置.
     
     <必选>

     - parameter imageBrowser: 图片浏览器.
     - parameter index: 图片索引.
     - parameter completion: 获取图片资源时的完成回调.
     */
    func mediaBrowser(_ imageBrowser: WRImageBrowserViewController, imageAt index: Int, completion: @escaping CompletionBlock)
}

// MARK:- WRImageBrowserViewControllerDelegate
public protocol WRImageBrowserViewControllerDelegate: class {
    /**
     当前展示的图片索引回调 .
     
     <可选>
     
     - parameter imageBrowser: 图片浏览器.
     - parameter index: 图片索引.
     - note:
        第一次加载时不会调用此方法，并且仅在左右滑动时才会调用此方法.
     */
    func mediaBrowser(_ imageBrowser: WRImageBrowserViewController, didChangeFocusTo index: Int)
}

extension WRImageBrowserViewControllerDelegate {
    public func mediaBrowser(_ mediaBrowser: WRImageBrowserViewController, didChangeFocusTo index: Int) {}
}

// MARK:- ZoomScale
/// 图片的缩放倍数
public struct ZoomScale {

    /// 最小缩放级别.
    public var minimumZoomScale: CGFloat

    /// 最大缩放级别.
    public var maximumZoomScale: CGFloat

    /// 默认缩放级别，1.0 ～ 3.0
    public static let `default` = ZoomScale(
        minimum: 1.0,
        maximum: 3.0
    )

    /// 缩放比例。通过此可禁用缩放.
    public static let identity = ZoomScale(
        minimum: 1.0,
        maximum: 1.0
    )

    /**
     初始化.
     - parameter minimum: 最小缩放级别.
     - parameter maximum: 最大缩放级别.
     */
    public init(minimum: CGFloat, maximum: CGFloat) {

        minimumZoomScale = minimum
        maximumZoomScale = maximum
    }
}

// MARK: - WRImageBrowserViewControllerConstants
fileprivate typealias WRImageBrowserViewControllerConstants = WRImageBrowserViewController
extension WRImageBrowserViewControllerConstants {
    internal enum Constants {

        static let gapBetweenContents: CGFloat = 50.0
        static let minimumVelocity: CGFloat = 15.0
        static let minimumTranslation: CGFloat = 0.3
        static let animationDuration = 0.3
        static let updateFrameRate: CGFloat = 60.0
        static let bounceFactor: CGFloat = 0.1
        static let controlHideDelay = 3.0

        enum Close {

            static let top: CGFloat = 8.0
            static let trailing: CGFloat = -8.0
            static let height: CGFloat = 30.0
            static let minWidth: CGFloat = 30.0
            static let contentInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
            static let borderWidth: CGFloat = 2.0
            static let borderColor: UIColor = .white
            static let title = "Close"
        }

        enum PageControl {

            static let bottom: CGFloat = -10.0
            static let tintColor: UIColor = .lightGray
            static let selectedTintColor: UIColor = .white
        }

        enum Title {
            static let top: CGFloat = 16.0
            static let rect: CGRect = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
    }
}

