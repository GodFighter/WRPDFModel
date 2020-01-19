//
//  WRPDFScrollView.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/17.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class WRPDFScrollView: UIScrollView, UIScrollViewDelegate {

    var pageRect = CGRect()
    var backgroundImageView: UIView!
    var tiledPDFView: WRPDFView!
    var oldTiledPDFView: WRPDFView!
    var PDFScale = CGFloat()
    var tiledPDFPage: CGPDFPage!
        
    var minRect : CGRect = .zero
    
    var tapBlock: (() -> ())?
    

    func initialize() {
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self

        minimumZoomScale = 0.5
        maximumZoomScale = 5
        backgroundImageView = UIView(frame: frame)
        self.addSubview(backgroundImageView)
        oldTiledPDFView = WRPDFView(frame: pageRect, scale: PDFScale)
        
        backgroundImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(action_tap(_:))))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    func setPDFPage(_ newPDFPage: CGPDFPage?) {
        // note: calls to CGPDFPageRetain and CGPDFPageRelease in the Objective-C version are not necessary here because CF objects are automatically memory managed in Swift.

        tiledPDFPage = newPDFPage

        // PDFPage is null if we're requested to draw a padded blank page by the parent UIPageViewController
        if tiledPDFPage == nil {
            pageRect = bounds
        } else {
            pageRect = tiledPDFPage.getBoxRect(CGPDFBox.mediaBox)

            PDFScale = frame.size.width / pageRect.size.width
            pageRect = CGRect(x: pageRect.origin.x, y: ceil((self.bounds.height - ceil(pageRect.size.height * PDFScale)) / 2.0), width: ceil(pageRect.size.width * PDFScale), height: ceil(pageRect.size.height * PDFScale))
        }

        // Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
        replaceTiledPDFViewWithFrame(pageRect)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Center the image as it becomes smaller than the size of the screen.
        let boundsSize:CGSize = bounds.size
        var frameToCenter:CGRect = tiledPDFView.frame

        // Center horizontally.
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        // Center vertically.
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        tiledPDFView.frame = frameToCenter
        backgroundImageView.frame = frameToCenter

        /*
         To handle the interaction between CATiledLayer and high resolution screens, set the tiling view's contentScaleFactor to 1.0.
         If this step were omitted, the content scale factor would be 2.0 on high resolution screens, which would cause the CATiledLayer to ask for tiles of the wrong scale.
         */
        tiledPDFView.contentScaleFactor = 1.0
        if minRect.equalTo(.zero) {
            minRect = pageRect
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return tiledPDFView
    }



    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?)
    {
        
        // Remove back tiled view.
        oldTiledPDFView.removeFromSuperview()

        // Set the current TiledPDFView to be the old view.
        oldTiledPDFView = tiledPDFView
        
    }

    /*
     A UIScrollView delegate callback, called when the user begins zooming.
     When the user begins zooming, remove the old TiledPDFView and set the current TiledPDFView to be the old view so we can create a new TiledPDFView when the zooming ends.
     */
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    {
        // Set the new scale factor for the TiledPDFView.
        PDFScale *= scale
        
        replaceTiledPDFViewWithFrame(oldTiledPDFView.frame.width < self.bounds.width ? minRect : oldTiledPDFView.frame)
    }


    func replaceTiledPDFViewWithFrame(_ frame: CGRect) {
        // Create a new tiled PDF View at the new scale
        let newTiledPDFView = WRPDFView(frame: frame, scale: PDFScale)
        newTiledPDFView.pdfPage = tiledPDFPage

        // Add the new TiledPDFView to the PDFScrollView.
        addSubview(newTiledPDFView)
        tiledPDFView = newTiledPDFView
//        tiledPDFView.layer.setNeedsDisplay()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.tiledPDFView.layer.setNeedsDisplay()
//        }

    }
    
    @objc func action_tap(_ sender: Any) {
        self.tapBlock?()
    }

}
