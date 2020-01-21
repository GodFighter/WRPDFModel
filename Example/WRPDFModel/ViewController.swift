//
//  ViewController.swift
//  WRPDFModel
//
//  Created by GodFighter on 01/15/2020.
//  Copyright (c) 2020 GodFighter. All rights reserved.
//

import UIKit
import WRPDFModel

class ViewController: UIViewController {

    var isappeared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let outlines = model.outlines
//        let pages = model.pages
        
//        print("\(outlines)")
        
//        let pdfView = WRPDFView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
//        pdfView.pdfPage = model.document?.page(at: 10)
//        self.view.addSubview(pdfView)
        
//
//        var pageRect = pdfView.pdfPage?.getBoxRect(.mediaBox)
//        pageRect = CGRect(x: (pageRect?.origin.x)!, y: (pageRect?.origin.y)!, width: (pageRect?.size.width)! , height: (pageRect?.size.height)! )
//        if #available(iOS 10.0, *) {
//            let render = UIGraphicsImageRenderer(size: pageRect!.size)
//            let image = render.image { (ctx) in
//                UIColor.clear.set()
//                ctx.fill(pageRect!)
//
//                ctx.cgContext.translateBy(x: 0.0, y: pageRect!.size.height)
//                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
//
//                ctx.cgContext.drawPDFPage(pdfView.pdfPage!)
//            }
//
//            let imageview = UIImageView(image: ViewController.tintColor(image, tintColor: .blue))
//            imageview.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 500)
//            self.view.addSubview(imageview)
//        } else {
//
//
//
//        }
        /*
        guard let size = pageRect?.size else {
            return
        }
//        UIGraphicsBeginImageContext(size)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height), false, 6)

        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1, y: -1)
        ctx.concatenate((pdfView.pdfPage?.getDrawingTransform(.mediaBox, rect: pageRect!, rotate: 0, preserveAspectRatio: true))!)
        ctx.drawPDFPage(pdfView.pdfPage!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    
        let imageview = UIImageView(image: ViewController.tintColor(image, tintColor: .blue))
        imageview.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 500)
        self.view.addSubview(imageview)
*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WRPDFReaderConfig.shared.hasAnimated = false
        WRPDFReaderConfig.shared.isDark = true
        WRPDFReaderConfig.shared.showSearchItem = true
        
        WRPDFReaderConfig.shared.backImage = UIImage(named: "navigationBar_Back")

        if isappeared == false {
            isappeared = true

            let url = Bundle.main.url(forResource: "投资的常识1", withExtension: "pdf")
            let pdfController = WRPDFViewController.init(url!)
            self.present(pdfController, animated: true, completion: nil)
            
            pdfController.setOutlinesItem(image: UIImage(named: "navigationBar_Back"))

//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                pdfController.setPageController(.vertical)
//                pdfController.setOutlinesItem(image: UIImage(named: "navigationBar_Back"))
//            }
        }
        
//        let pdfController = WRPDFPageViewController.init()
//        pdfController.modalPresentationStyle = .fullScreen
//        self.present(pdfController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func action_back(_ sender: Any) {
        
    }

}

