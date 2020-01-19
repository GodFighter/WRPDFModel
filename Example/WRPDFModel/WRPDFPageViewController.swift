//
//  WRPDFViewController.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/17.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WRPDFModel

class WRPDFPageViewController: UIViewController {

    var scrollView: WRPDFScrollView!
    
    var pageNumber: Int = 18
    var myScale: CGFloat = 0

    var pdf: CGPDFDocument!
    var page: CGPDFPage!
    
    weak var pdfModel: WRPDFModel!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ pdfModel: WRPDFModel, pageNumber : Int) {
        self.init(nibName: nil, bundle: nil)
        self.pdfModel = pdfModel
        self.pageNumber = pageNumber

        self.scrollView = WRPDFScrollView()
        self.view.addSubview(scrollView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pdf = self.pdfModel.document
        self.page = pdf.page(at: self.pageNumber)
                
        scrollView.bounds = self.view.bounds
        scrollView.center = self.view.center
        scrollView.setPDFPage(page)
        scrollView.isUserInteractionEnabled = UIApplication.shared.statusBarOrientation.isPortrait
        
        self.view.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(action_dark(_:)), name: WRPDFReaderConfig.Notify.dark.name, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        restoreScale()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: { context in
            // Disable zooming if our pages are currently shown in landscape after orientation changes
            self.scrollView.isUserInteractionEnabled = UIApplication.shared.statusBarOrientation.isPortrait
        })
    }

    func restoreScale()
    {
        // Called on orientation change.
        // We need to zoom out and basically reset the scrollview to look right in two-page spline view.
        let pageRect = page.getBoxRect(CGPDFBox.mediaBox)
        let yScale = view.frame.size.height / pageRect.size.height
        let xScale = view.frame.size.width / pageRect.size.width
        myScale = min(xScale, yScale)
        scrollView.bounds = view.bounds
        scrollView.zoomScale = 1.0
        scrollView.PDFScale = myScale
        scrollView.tiledPDFView.bounds = view.bounds
        scrollView.tiledPDFView.myScale = myScale
        scrollView.tiledPDFView.layer.setNeedsDisplay()
    }


    @objc func action_dark(_ notification: Notification) {
        if let _ = notification.object as? Bool {
            self.view.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        }
    }

}
