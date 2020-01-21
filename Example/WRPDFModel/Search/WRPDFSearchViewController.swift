//
//  WRPDFSearchViewController.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/21.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WRPDFModel

class WRPDFSearchViewController: UIViewController {

    weak var pdfModel: WRPDFModel!
    var collectionView: UICollectionView!
    var results = [(Int, String)]()
    var searchText: String?
    var currentPage: Int = 1 {
        didSet {
            if let footer = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 1)) as? WRPDFSearchFooterView {
                footer.setConfig(result: WRPDFReaderConfig.shared.searchResult(results.count), pageCount: "\(self.currentPage)/\(pdfModel.document?.numberOfPages ?? 0)")
            }
        }
    }

    weak var stopBarButtonItem: UIBarButtonItem!

    var selectedPageBlock: ((Int) -> ())?
    
    fileprivate var isStopEnable = false {
        didSet{
            self.stopBarButtonItem.isEnabled = self.isStopEnable
        }
    }

    convenience init(_ pdfModel : WRPDFModel) {
        self.init(nibName: nil, bundle: nil)
        self.pdfModel = pdfModel
        

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            var leftItems = [UIBarButtonItem]()
            
            var backItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(action_close))
            if let barTitle = WRPDFReaderConfig.shared.backTitle {
                backItem = UIBarButtonItem.init(title: barTitle, style: .plain, target: self, action: #selector(action_close))
            } else if let barImage = WRPDFReaderConfig.shared.backImage {
                backItem = UIBarButtonItem.init(image: barImage, style: .plain, target: self, action: #selector(action_close))
            }
            
            leftItems.append(backItem)
            self.navigationItem.leftBarButtonItems = leftItems
        }
        
        do {
            let stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(action_stop))
            stopItem.isEnabled = isStopEnable
            self.navigationItem.rightBarButtonItem = stopItem
            stopBarButtonItem = stopItem
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(WRPDFViewController.color((self.navigationController?.navigationBar.bounds.size)!, WRPDFReaderConfig.shared.navigationBarColor)
            , for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = WRPDFReaderConfig.shared.navigationTintColor
        
        do {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionHeadersPinToVisibleBounds = true
            layout.sectionFootersPinToVisibleBounds = true

            collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
            self.view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.register(WRPDFHorizontalOutlineCell.self, forCellWithReuseIdentifier: "WRPDFHorizontalOutlineCell")
            collectionView.register(WRPDFSearchHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
            collectionView.register(WRPDFSearchFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")

            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
            
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
}

//MARK: -
fileprivate typealias WRPDFSearchViewController_Action = WRPDFSearchViewController
extension WRPDFSearchViewController_Action {
    @objc func action_close() {
        pdfModel.searchStop()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func action_stop() {
        self.pdfModel.searchStop()
        isStopEnable = false
    }
    
    @objc func action_search(_ text: String) {
        results.removeAll()
        currentPage = 1
        isStopEnable = true
        
        self.pdfModel.search(text) { [weak self] (page, values, finished) in
            guard let strong_self = self else {
                return
            }
                
            strong_self.isStopEnable = !finished

            var addIndexPaths = [IndexPath]()
                        
            values.forEach { (_) in
                addIndexPaths.append(IndexPath(item: max(strong_self.results.count, 0), section: 1))
            }
            
            if addIndexPaths.count == 0 {
                strong_self.currentPage = page
                return
            }
            
            if #available(iOS 11.0, *) {
                strong_self.collectionView.performUsingPresentationValues {
                    let value = values.map { (result) -> (Int, String) in
                        return (page, result)
                    }
                    strong_self.results.append(contentsOf: value)
                    if strong_self.results.count == 0 {
                        strong_self.collectionView.reloadSections([1])
                    } else {
                        strong_self.collectionView.insertItems(at: addIndexPaths)
                    }
                }
            } else {
                strong_self.collectionView.insertItems(at: addIndexPaths)
                let value = values.map { (result) -> (Int, String) in
                    return (page, result)
                }
                strong_self.results.append(contentsOf: value)
            }
        }
    }
}

//MARK: -
fileprivate typealias WRPDFSearchViewController_TextField = WRPDFSearchViewController
extension WRPDFSearchViewController_TextField : UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        action_stop()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        
        guard let text = textField.text else {
            return false
        }
        action_search(text)
        
        return true
    }
}

//MARK: -
fileprivate typealias WRPDFSearchViewController_CollectionView = WRPDFSearchViewController
extension WRPDFSearchViewController_CollectionView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result = results[indexPath.item]
        selectedPageBlock?(max(1, result.0))
        self.action_close()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 0 : results.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier : String = {
            return "WRPDFHorizontalOutlineCell"
        }()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let cell = cell as? WRPDFHorizontalOutlineCell {
            cell.setConfig(results[indexPath.item], search: searchText ?? "")
        }
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath:
        IndexPath) -> UICollectionReusableView {
        let identifier : String = {
            return kind == UICollectionView.elementKindSectionHeader ? "Header" : "Footer"
        }()
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        if let header = view as? WRPDFSearchHeaderView {
            header.searchTextField.delegate = self
        } else if let footer = view as? WRPDFSearchFooterView {
            guard results.count > 0 else {
                return view
            }
            
            let result = results[indexPath.item]
            footer.setConfig(result: WRPDFReaderConfig.shared.searchResult(results.count), pageCount: "\(result.0)/\(pdfModel.document?.numberOfPages ?? 0)")
        }
        
        return view
    }

    //MARK: CollectionFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height : CGFloat = {
            return 50
        }()

        return CGSize(width: collectionView.bounds.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize(width: collectionView.bounds.width, height: 50) : .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section != 0 && results.count > 0 {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
        return .zero
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
