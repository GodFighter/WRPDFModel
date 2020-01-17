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

    init(frame: CGRect, scale: CGFloat) {
        super.init(frame: frame)
        
        let tiledLayer = CATiledLayer(layer: self)
        tiledLayer.levelsOfDetail = 4
        tiledLayer.levelsOfDetailBias = 3
        
//        tiledLayer.tileSize = CGSize(width: 200, height: 200)
        myScale = scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static var layerClass: AnyClass {
        get {
//            return CALayer.self
            return CATiledLayer.self
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
                UIColor.clear.set()
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
                    self.pdfImage = WRPDFView.tintColor(self.image(), tintColor: .red)
                }
            } else {
                self.pdfImage = WRPDFView.tintColor(self.image(), tintColor: .red)
            }
        }
        
        ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ctx.setStrokeColor(UIColor.red.cgColor)
//        
        ctx.fill(self.bounds)

        // Print a blank page and return if our page is nil.
        if ( self.pdfPage == nil )
        {
            print("page nil")
            return
        }

        // save the cg state
        ctx.saveGState()
        

        // Flip the context so that the PDF page is rendered right side up.
        ctx.translateBy(x: 0.0, y: self.bounds.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)

        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
//        ctx.scaleBy(x: self.myScale, y: self.myScale)

        ctx.setBlendMode(.darken)


        // draw the page, restore and exit
        
        let height = self.pdfImage!.size.height / self.pdfImage!.size.width * self.bounds.width
        let y = (self.bounds.height - height) / 2.0
        
        ctx.draw((self.pdfImage?.cgImage)!, in: CGRect(x: 0, y:  y, width: self.bounds.width, height: height), byTiling: false)
//        ctx.drawPDFPage(self.pdfPage!)
//        ctx.setBlendMode(.exclusion)
//        ctx.drawPDFPage(self.pdfPage!)

        ctx.restoreGState()
    }

    
    fileprivate static func tintColor(_ image : UIImage, tintColor: UIColor) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
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

}
