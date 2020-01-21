//
//  WRPDFViewController.swift
//  WRPDFModel_Example
//
//  Created by xianghui-iMac on 2020/1/18.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WRPDFModel

@objc open class WRPDFViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    
    var pdf: WRPDFModel?
    var url : URL!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.pdf = nil
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
        
    convenience init(_ url : URL) {
        self.init(nibName: nil, bundle: nil)
        self.url = url
        self.pdf = WRPDFModel(url)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.pdf!.searchStop()
//        }

        setPageController(UIPageViewController.NavigationOrientation.horizontal)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad(){

        super.viewDidLoad()
        
        self.modalPresentationStyle = .fullScreen

        if WRPDFReaderConfig.shared.showSearchItem {
//            let searcj
        }

    }
    
    func viewControllerAt(_ index: Int, isBack: Bool) -> UIViewController {
        let controller = isBack ? WRPDFBackPageViewController.init(index + 1) : WRPDFPageViewController.init(self.pdf!, pageNumber: index + 1)
        if let viewController = controller as? WRPDFPageViewController {
            viewController.scrollView.tapBlock = { [weak self] in
                self?.pageViewController?.navigationController?.setNavigationBarHidden(!(self?.pageViewController?.navigationController?.navigationBar.isHidden ?? true), animated: true)
            }
        }
        return controller
    }

    func indexOf(_ viewController : UIViewController) -> Int {
        if let pageController = viewController as? WRPDFPageViewController {
            return pageController.pageNumber - 1
        }
        return (viewController as! WRPDFBackPageViewController).pageNumber - 1
    }
    
    @objc func action_dark(_ notification: Notification) {
        if let _ = notification.object as? Bool {
            pageViewController.view.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        }
    }
    
    @objc func action_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    internal static func color(_ size : CGSize, _ color : UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else{
            return nil
        }
        
        color.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}

//MARK: -
fileprivate typealias WRPDFViewController_Action = WRPDFViewController
public extension WRPDFViewController_Action{
    @objc func action_edit(_ sender: UIBarButtonItem) {
        
    }
}

//MARK: -
fileprivate typealias WRPDFViewController_Access = WRPDFViewController
public extension WRPDFViewController_Access{
    @objc func access_outlinesController() {
                
        let outlinesController = WRPDFOutlinesViewController(self.pdf!.outlines)
        let navigationController = UINavigationController(rootViewController: outlinesController)
        self.present(navigationController, animated: true, completion: nil)

        outlinesController.selectedPageBlock = { [weak self] (page) in
            if let startViewController = self?.viewControllerAt(page, isBack: false) {
                let viewControllers = [startViewController]
                self?.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            }
        }
    }
    
    @objc func access_searchController() {
        let searchController = WRPDFSearchViewController.init(self.pdf!)
        let navigationController = UINavigationController(rootViewController: searchController)
        self.present(navigationController, animated: true, completion: nil)
        
        searchController.selectedPageBlock = { [weak self] (page) in
            if let startViewController = self?.viewControllerAt(page, isBack: false) {
                let viewControllers = [startViewController]
                self?.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            }
        }
    }
}

//MARK: -
fileprivate typealias WRPDFViewController_Public = WRPDFViewController
public extension WRPDFViewController_Public{
    
    @objc func setBackItem(image: String? = nil, title: String? = nil) {
        
    }
    
    @objc func setOutlinesItem(image: UIImage? = nil, title: String? = nil) {
        WRPDFReaderConfig.shared.outlinesImage = image
        WRPDFReaderConfig.shared.outlinesTitle = title

        self.pdf!.getOutlines { [weak self] (outlines) in
            guard let strongSelf = self, outlines.count > 0 else {
                return
            }
            
            guard let _ = strongSelf.pageViewController.navigationItem.leftBarButtonItems?.first(where: { (item) -> Bool in
                return item.action == #selector(strongSelf.access_outlinesController)
            
            }) else  {
                var outlinesItem = UIBarButtonItem.init(barButtonSystemItem: .bookmarks, target: strongSelf, action:#selector(strongSelf.access_outlinesController))
                if let barTitle = title {
                    outlinesItem = UIBarButtonItem.init(title: barTitle, style: .plain, target: strongSelf, action: #selector(strongSelf.access_outlinesController))
                } else if let barImage = WRPDFReaderConfig.shared.outlinesImage {
                    outlinesItem = UIBarButtonItem.init(image: barImage, style: .plain, target: strongSelf, action: #selector(strongSelf.access_outlinesController))
                }
                if var leftItems = strongSelf.pageViewController.navigationItem.leftBarButtonItems {
                    leftItems.append(outlinesItem)
                    strongSelf.pageViewController.navigationItem.setLeftBarButtonItems(leftItems, animated: true)
                }
                return
            }
        }
    }
    
    @objc func setPageController(_ direction: UIPageViewController.NavigationOrientation) {
        clearChildController()
        
        let transitionStyle : UIPageViewController.TransitionStyle = WRPDFReaderConfig.shared.hasAnimated ? .pageCurl : .scroll
        pageViewController = UIPageViewController(transitionStyle: transitionStyle, navigationOrientation: direction, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.isDoubleSided = pageViewController.transitionStyle == .pageCurl

        let startViewController = self.viewControllerAt(0,isBack: false)
        let viewControllers = [startViewController]
        
        let navigationController = UINavigationController(rootViewController: pageViewController)
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        
        self.addChild(navigationController)
        self.view.addSubview(navigationController.view)
        
        let pageViewRect = self.view.bounds
        pageViewController.view.frame = pageViewRect
        navigationController.didMove(toParent: self)
        
        pageViewController.view.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(action_dark(_:)), name: WRPDFReaderConfig.Notify.dark.name, object: nil)
        
        setNavigationBar()
    }
}

//MARK: -
fileprivate typealias WRPDFViewController_Private = WRPDFViewController
private extension WRPDFViewController_Private {
    func clearChildController() {
        pageViewController?.navigationController?.view.removeFromSuperview()
        pageViewController?.navigationController?.removeFromParent()
    }
    func setNavigationBar() {
        
        /*leftItems*/
        do {
            var leftItems = [UIBarButtonItem]()
            
            var backBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(action_back(_:)))

            if let barTitle = WRPDFReaderConfig.shared.backTitle {
                backBarButtonItem = UIBarButtonItem.init(title: barTitle, style: .plain, target: self, action: #selector(action_back(_:)))
            } else if let barImage = WRPDFReaderConfig.shared.backImage {
                backBarButtonItem = UIBarButtonItem.init(image: barImage, style: .plain, target: self, action: #selector(action_back(_:)))
            }
            leftItems.append(backBarButtonItem)

            pageViewController.navigationItem.leftBarButtonItems = leftItems
        }
        
        /*rightItems*/
        do {
            var rightItems = [UIBarButtonItem]()

            var editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(action_edit(_:)))
            if let editTitle = WRPDFReaderConfig.shared.menuTitle  {
                editItem = UIBarButtonItem.init(title: editTitle, style: .plain, target: self, action: #selector(action_edit(_:)))
            } else if let editImage = WRPDFReaderConfig.shared.menuImage {
                editItem = UIBarButtonItem(image: editImage, style: .plain, target: self, action: #selector(action_edit(_:)))
            }
            rightItems.append(editItem)

            if WRPDFReaderConfig.shared.showSearchItem {
                var searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(access_searchController))
                if let seachTitle = WRPDFReaderConfig.shared.searchTitle {
                    searchItem = UIBarButtonItem.init(title: seachTitle, style: .plain, target: self, action: #selector(access_searchController))
                } else if let seachImage = WRPDFReaderConfig.shared.searchImage {
                    searchItem = UIBarButtonItem(image: seachImage, style: .plain, target: self, action: #selector(access_searchController))
                }
                rightItems.append(searchItem)
            }
            
            pageViewController.navigationItem.rightBarButtonItems = rightItems
        }
    pageViewController.navigationController?.navigationBar.setBackgroundImage(WRPDFViewController.color((pageViewController.navigationController?.navigationBar.bounds.size)!, WRPDFReaderConfig.shared.navigationBarColor)
            , for: .default)
        // 纯色的图片，isTranslucent为no，会从y=64开始绘制
        pageViewController.navigationController?.navigationBar.isTranslucent = true
        pageViewController.navigationController?.navigationBar.tintColor = WRPDFReaderConfig.shared.navigationTintColor
    }
}

//MARK: -
fileprivate typealias WRPDFViewController_PageViewControllerDataSource = WRPDFViewController
extension WRPDFViewController_PageViewControllerDataSource : UIPageViewControllerDataSource{
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
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
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOf(viewController)
        if index < 0 || index + 1 > self.pdf!.document!.numberOfPages {
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
    public func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        if orientation.isPortrait || UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.

            let currentViewController = pageViewController.viewControllers![0] as UIViewController
            let viewControllers = [currentViewController]
            pageViewController.setViewControllers(viewControllers, direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
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
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        print("\(pendingViewControllers)")
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
    }
}


