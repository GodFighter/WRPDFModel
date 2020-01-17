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

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "投资的常识1", withExtension: "pdf")
        let model = WRPDFModel(url!)

        self.pdf = model.document
        self.page = pdf.page(at: self.pageNumber)
        
        
        self.scrollView = WRPDFScrollView()
        self.view.addSubview(scrollView)
        scrollView.center = self.view.center
        scrollView.backgroundColor = .red
        scrollView.setPDFPage(page)
        scrollView.isUserInteractionEnabled = UIApplication.shared.statusBarOrientation.isPortrait
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
