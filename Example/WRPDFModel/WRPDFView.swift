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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(frame: CGRect, scale: CGFloat) {
        super.init(frame: frame)
        
        let tiledLayer = CATiledLayer(layer: self)
        tiledLayer.levelsOfDetail = 4
        tiledLayer.levelsOfDetailBias = 3
        
        myScale = scale
        
        NotificationCenter.default.addObserver(self, selector: #selector(action_dark(_:)), name: WRPDFReaderConfig.Notify.dark.name, object: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static var layerClass: AnyClass {
        get {
            return WRPDFReaderConfig.shared.isTiled ? CATiledLayer.self : CALayer.self
        }
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
           
    }
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        if self.pdfImage == nil {
            if self.layer.isKind(of: CATiledLayer.self) {
                DispatchQueue.main.sync {
                    
                    var image = self.image()
                    
                    image = WRPDFView.grayImage(image)!

                    if WRPDFReaderConfig.shared.isDark {
                        self.pdfImage = WRPDFView.tintColor(WRPDFView.grayImage(self.image())!, tintColor: .black)
                    } else {
                        self.pdfImage = self.image()
                    }
                }
            } else {
                if WRPDFReaderConfig.shared.isDark {
                    self.pdfImage = WRPDFView.tintColor(WRPDFView.grayImage(self.image())!, tintColor: .black)
                } else {
                    self.pdfImage = self.image()
                }
                
            }
        }
        
        ctx.setFillColor(WRPDFReaderConfig.shared.backgroundColor.cgColor)
        ctx.fill(self.bounds)
        ctx.saveGState()
        ctx.restoreGState()

        
        ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let scale = self.pdfImage!.size.height / self.pdfImage!.size.width
        
        let height = scale * self.bounds.width

        ctx.fill(CGRect(x: 0, y: (self.bounds.height - height) / 2.0, width: self.bounds.width, height: height))

        // Print a blank page and return if our page is nil.
        if ( self.pdfPage == nil ) {
            print("page nil")
            return
        }

        // save the cg state
        ctx.saveGState()

        // Flip the context so that the PDF page is rendered right side up.
        ctx.translateBy(x: 0.0, y: self.bounds.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)

        let y : Int = Int((self.bounds.height - height) / 2.0)
//
        ctx.draw((self.pdfImage?.cgImage)!, in: CGRect(x: 0, y:  CGFloat(y), width: self.bounds.width, height: ceil(height)), byTiling: false)
//        ctx.drawPDFPage(self.pdfPage!)
        
        ctx.restoreGState()
    }

    
    fileprivate static func tintColor(_ image : UIImage, tintColor: UIColor) -> UIImage? {

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
            return grayImage
            
        }
    
    @objc func action_dark(_ notification: Notification) {
        if let _ = notification.object as? Bool {
            self.pdfImage = nil
            self.setNeedsDisplay()
        }
    }

}
