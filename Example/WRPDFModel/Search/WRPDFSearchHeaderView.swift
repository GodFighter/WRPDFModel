//
//  WRPDFSearchHeaderView.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/21.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class WRPDFSearchHeaderView: UICollectionReusableView {
    
    var searchTextField: WRSearchTextField!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        layer.shadowColor = WRPDFReaderConfig.shared.outlineLineColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 1
        
        do {
            searchTextField = WRSearchTextField.init(frame: self.bounds)
            addSubview(searchTextField)
            searchTextField.leftViewMode = .always
            searchTextField.returnKeyType = .search
            searchTextField.leftView = {
                var leftView = UIImageView.init(frame: CGRect(x: 30, y: 0, width: 30, height: searchTextField.bounds.height))
                if WRPDFReaderConfig.shared.searchImage != nil {
                    let image = WRPDFReaderConfig.shared.searchImage!
                    leftView = UIImageView(image: image)
                    leftView.frame = CGRect(x: 30, y: 0, width: image.size.width + 30, height: image.size.height)
                }
                leftView.contentMode = .center
                return leftView
            }()
            searchTextField.translatesAutoresizingMaskIntoConstraints = false
            searchTextField.borderStyle = .none
            searchTextField.textColor = UIColor.systemTeal
            if #available(iOS 13, *) {
                searchTextField.textColor = UIColor.label
            }
            searchTextField.backgroundColor = UIColor.systemGray
            searchTextField.layer.cornerRadius = (frame.height - 10) / 2.0
            
            do {
                addConstraints([
                    NSLayoutConstraint(item: searchTextField!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20),
                    NSLayoutConstraint(item: searchTextField!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20),
                    NSLayoutConstraint(item: searchTextField!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 5),
                    NSLayoutConstraint(item: searchTextField!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -5)
                ])
            }
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class WRSearchTextField: UITextField {
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: 30, height: bounds.height)
    }
}
