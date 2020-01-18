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

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func updateWithViewController(_ controller: UIViewController) {
        self.image = self.captureImage(controller.view)
        self.view.backgroundColor = .red
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

    
}
