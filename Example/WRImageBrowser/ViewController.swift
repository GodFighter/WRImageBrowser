//
//  ViewController.swift
//  WRImageBrowser
//
//  Created by GodFighter on 09/28/2020.
//  Copyright (c) 2020 GodFighter. All rights reserved.
//

import UIKit
import WRImageBrowser

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton.init(type: .system)
        view.addSubview(button)
        
        button.setTitle("图片", for: .normal)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        button.addTarget(self, action: #selector(_actionClick), for: .touchUpInside)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func _actionClick() {
        let controller = WRImageBrowserViewController(dataSource: self)
        controller.gapBetweenMediaViews = 0
        controller.contentTransformer = WRImageContentTransformers.Horizotal.MoveIn
        present(controller, animated: true, completion: nil)
        
    }

}


extension ViewController: WRImageBrowserViewControllerDataSource {
    func numberOfItems(in imageBrowser: WRImageBrowserViewController) -> Int {
        2
    }

    func mediaBrowser(_ imageBrowser: WRImageBrowserViewController, imageAt index: Int, completion: @escaping CompletionBlock) {
        completion(index, UIImage(named: "Image"), ZoomScale.default, nil)
    }
    
}
