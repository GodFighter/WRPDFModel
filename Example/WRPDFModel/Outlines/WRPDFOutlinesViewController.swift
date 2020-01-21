//
//  WRPDFOutlinesViewController.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WRPDFModel

@objc class WRPDFOutlinesViewController: UIViewController {

    var collectionView: UICollectionView!
    var outlines = [WROutline]()
    
    var selectedPageBlock: ((Int) -> ())?
    
    convenience init(_ outlines : [WROutline]) {
        self.init(nibName: nil, bundle: nil)
        self.outlines = outlines
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var leftItems = [UIBarButtonItem]()
        var backItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(action_close))
        
        if let barTitle = WRPDFReaderConfig.shared.backTitle {
            backItem = UIBarButtonItem.init(title: barTitle, style: .plain, target: self, action: #selector(action_close))
        } else if let barImage = WRPDFReaderConfig.shared.backImage {
            backItem = UIBarButtonItem.init(image: barImage, style: .plain, target: self, action: #selector(action_close))
        }
        leftItems.append(backItem)

        self.navigationItem.leftBarButtonItems = leftItems

        self.navigationController?.navigationBar.setBackgroundImage(WRPDFViewController.color((self.navigationController?.navigationBar.bounds.size)!, WRPDFReaderConfig.shared.navigationBarColor)
            , for: .default)
        // 纯色的图片，isTranslucent为no，会从y=64开始绘制
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = WRPDFReaderConfig.shared.navigationTintColor

        let layout: UICollectionViewLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.register(WRPDFHorizontalOutlineCell.self, forCellWithReuseIdentifier: "WRPDFHorizontalOutlineCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var safeAreaInsetsTop: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeAreaInsetsTop = self.view.safeAreaInsets.top
        }
        
        self.view.addConstraints([
            NSLayoutConstraint(item: self.collectionView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: safeAreaInsetsTop),
            NSLayoutConstraint(item: self.collectionView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.collectionView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.collectionView!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0)
        ])
    }
}

//MARK: -
fileprivate typealias WRPDFOutlinesViewController_Action = WRPDFOutlinesViewController
extension WRPDFOutlinesViewController_Action {
    @objc func action_close() {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: -
fileprivate typealias WRPDFOutlinesViewController_CollectionView = WRPDFOutlinesViewController
extension WRPDFOutlinesViewController_CollectionView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let outline = outlines[indexPath.section]
        if outline.subOutlines.count > 0, outline.isOpen == false {
            outline.isOpen = true
            collectionView.reloadSections([indexPath.section])
            
            return
        }
        var selectedOutline = outline
        if indexPath.item > 0 {
            selectedOutline = outline.subOutlines[indexPath.item - 1]
        }
        outline.isOpen = false
        selectedPageBlock?(max(0, selectedOutline.page - 1))
        self.action_close()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return outlines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let outline = outlines[section]
        
        return outline.isOpen ? outline.subOutlines.count + 1 : 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier : String = {
            return "WRPDFHorizontalOutlineCell"
        }()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        let outline = indexPath.item == 0 ? outlines[indexPath.section] : outlines[indexPath.section].subOutlines[indexPath.item - 1]
        
        if let cell = cell as? WRPDFHorizontalOutlineCell {
            cell.setConfig(outline)
        }

        return cell

    }

    //MARK: CollectionFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height : CGFloat = {
            return 50
        }()

        return CGSize(width: collectionView.bounds.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return .zero
    }
}

