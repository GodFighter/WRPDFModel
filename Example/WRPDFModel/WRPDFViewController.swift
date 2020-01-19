//
//  WRPDFViewController.swift
//  WRPDFModel_Example
//
//  Created by xianghui-iMac on 2020/1/18.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WRPDFModel

class WRPDFViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    
    var pdf: WRPDFModel!
    var url : URL!
    
    fileprivate var tempNumber:NSInteger = 1

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
        
    convenience init(_ url : URL) {
        self.init(nibName: nil, bundle: nil)
        self.url = url
        self.pdf = WRPDFModel(url)
}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){

        super.viewDidLoad()
    
        let transitionStyle : UIPageViewController.TransitionStyle = WRPDFReaderConfig.shared.hasAnimated ? .pageCurl : .scroll
        

        pageViewController = UIPageViewController(transitionStyle: transitionStyle, navigationOrientation: .horizontal, options: nil)
        pageViewController.isDoubleSided = pageViewController.transitionStyle == .pageCurl
        pageViewController.delegate = self
        pageViewController.dataSource = self

        let startViewController = self.viewControllerAt(0,isBack: false)
        let viewControllers = [startViewController]
        
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        
        let pageViewRect = self.view.bounds
        pageViewController.view.frame = pageViewRect
        pageViewController.didMove(toParent: self)
    }
    
    func viewControllerAt(_ index: Int, isBack: Bool) -> UIViewController {
        let controller = isBack ? WRPDFBackPageViewController() : WRPDFPageViewController()
        if let viewController = controller as? WRPDFBackPageViewController {
            viewController.pageNumber = index + 1
        } else if let viewController = controller as? WRPDFPageViewController {
            viewController.page = self.pdf.document?.page(at: index + 1)
            viewController.pageNumber = index + 1
        }
        return controller
    }

    func indexOf(_ viewController : UIViewController) -> Int {
        if let pageController = viewController as? WRPDFPageViewController {
            return pageController.pageNumber - 1
        }
        return (viewController as! WRPDFBackPageViewController).pageNumber - 1
    }
    

    
}

//MARK: -
fileprivate typealias WRPDFViewController_PageViewControllerDataSource = WRPDFViewController
extension WRPDFViewController_PageViewControllerDataSource : UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOf(viewController)
        if index <= 0 {
            return nil
        }

        let isBack = pageViewController.isDoubleSided && viewController.isKind(of: WRPDFPageViewController.self)

        if !isBack {
            index -= 1
        }

        let pageController = self.viewControllerAt(index, isBack: isBack)
        if let backPageController = pageController as? WRPDFBackPageViewController  {
            backPageController.updateWithViewController(viewController)
        }

        return pageController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOf(viewController)
        if index < 0 || index + 1 > self.pdf.document!.numberOfPages {
            return nil
        }
            
        let isBack = pageViewController.isDoubleSided && viewController.isKind(of: WRPDFPageViewController.self)

        if !isBack  {
            index += 1
        }
        
        let pageController = self.viewControllerAt(index, isBack: isBack)
        if let backPageController = pageController as? WRPDFBackPageViewController  {
            backPageController.updateWithViewController(viewController)
        }

        return pageController
    }
}

//MARK: -
fileprivate typealias WRPDFViewController_PageViewControllerDelegate = WRPDFViewController
extension WRPDFViewController_PageViewControllerDelegate : UIPageViewControllerDelegate{
    internal func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        if orientation.isPortrait || UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.

            let currentViewController = pageViewController.viewControllers![0] as UIViewController
            let viewControllers = [currentViewController]
            pageViewController.setViewControllers(viewControllers, direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
//            pageViewController.isDoubleSided = false
            return UIPageViewController.SpineLocation.min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = pageViewController.viewControllers?[0] as! WRPDFPageViewController

        var viewControllers:[UIViewController] = []
        let indexOfCurrentViewController = self.indexOf(currentViewController)

        if indexOfCurrentViewController % 2 == 0
        {
            let nextViewController: UIViewController = self.pageViewController(pageViewController, viewControllerAfter: currentViewController)!
            viewControllers = [currentViewController, nextViewController]
        }
        else
        {
            let previousViewController: UIViewController = self.pageViewController(pageViewController, viewControllerBefore: currentViewController)!
            viewControllers = [previousViewController, currentViewController]
        }

        pageViewController.setViewControllers(viewControllers, direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)

        return UIPageViewController.SpineLocation.mid
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
    }
}


