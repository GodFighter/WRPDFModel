//
//  WRPDFView.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/17.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
class WRPDFView: UIView {
    
    var pdfPage: CGPDFPage?
    var myScale: CGFloat!
    
    var pdfImage: UIImage?
    
    
    var imageView: UIImageView!

    deinit {
        self.imageView = nil
        self.pdfImage = nil
        NotificationCenter.default.removeObserver(self)
    }

    init(frame: CGRect, scale: CGFloat) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        
        myScale = scale
        
        NotificationCenter.default.addObserver(self, selector: #selector(action_dark(_:)), name: WRPDFReaderConfig.Notify.dark.name, object: nil)
        
        self.imageView = UIImageView()
        self.imageView.isUserInteractionEnabled = true
        self.addSubview(self.imageView)
                
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    fileprivate func image() -> UIImage {
        var image = UIImage()

        guard let pdfPage = self.pdfPage else {
            return image
        }
                
        let pageRect = pdfPage.getBoxRect(.mediaBox)

        let pageSize = pageRect.size
        
        if #available(iOS 10.0, *) {
            let render = UIGraphicsImageRenderer(size: pageSize)

            image = render.image { (ctx) in
                UIColor.white.set()
                ctx.fill(pageRect)

                ctx.cgContext.translateBy(x: 0.0, y: pageSize.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                ctx.cgContext.drawPDFPage(pdfPage)
            }

        } else {

            UIGraphicsBeginImageContextWithOptions(pageSize, false, UIScreen.main.scale)

            let ctx: CGContext = UIGraphicsGetCurrentContext()!
            ctx.saveGState()
            
            ctx.translateBy(x: 0, y: pageSize.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.scaleBy(x: self.myScale, y: self.myScale)

            ctx.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
            ctx.drawPDFPage(pdfPage)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return image
    }
    
    override func draw(_ rect: CGRect) {
           
        if self.pdfImage == nil {
            if WRPDFReaderConfig.shared.isDark {
                self.pdfImage = WRPDFView.tintColor(WRPDFView.grayImage(self.image())!, tintColor: .black)
            } else {
                self.pdfImage = self.image()
            }
        }

        let scale = self.pdfImage!.size.height / self.pdfImage!.size.width
        let height = ceil(scale * self.bounds.width)
        self.imageView.frame = CGRect(x: 0, y: ceil((self.bounds.height - height) / 2.0), width: self.bounds.width, height: height)
        self.imageView.backgroundColor = .white
        self.imageView.image = self.pdfImage!
 
    }
    
    internal static func tintColor(_ image : UIImage, tintColor: UIColor) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height) as CGRect
        if let cgImage = image.cgImage {
            context?.clip(to: rect, mask:  cgImage)
        }
        
        tintColor.setFill()
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    static func grayImage(_ image: UIImage) -> UIImage?
        {
            UIGraphicsBeginImageContext(image.size)
            let colorSpace = CGColorSpaceCreateDeviceGray()
            let context = CGContext(data: nil , width: Int(image.size.width * image.scale), height: Int(image.size.height * image.scale),bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
            
            context?.draw(image.cgImage!, in: CGRect.init(x: 0, y: 0, width: image.size.width * image.scale, height: image.size.height * image.scale))
            let cgImage = context!.makeImage()
            let grayImage = UIImage(cgImage: cgImage!, scale: image.scale, orientation: image.imageOrientation)
            UIGraphicsEndImageContext()
            return grayImage
            
        }
    
    @objc func action_dark(_ notification: Notification) {
        if let _ = notification.object as? Bool {
            self.pdfImage = nil
            self.setNeedsDisplay()
        }
    }
    
}
