//
//  WRPDFBackPageViewController.swift
//  WRPDFModel_Example
//
//  Created by xianghui-iMac on 2020/1/18.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class WRPDFBackPageViewController: UIViewController {
    
    var image: UIImage?
    var imageview: UIImageView!
    var pageNumber: Int = 18

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    convenience init(_ pageNumber : Int) {
        self.init(nibName: nil, bundle: nil)
        self.pageNumber = pageNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(action_dark(_:)), name: WRPDFReaderConfig.Notify.dark.name, object: nil)

    }
    
    func updateWithViewController(_ controller: UIViewController) {
        self.image = self.captureImage(controller.view)
        if imageview == nil {
            imageview = UIImageView()
            self.view.addSubview(imageview)
            imageview.bounds = self.view.bounds
            imageview.center = self.view.center
//            imageview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageview.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
        }
        if let image = self.image {
            imageview.image = image
        }
    }
    
    func captureImage(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }

    @objc func action_dark(_ notification: Notification) {
        if let _ = notification.object as? Bool {
            self.view.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        }
    }

}
