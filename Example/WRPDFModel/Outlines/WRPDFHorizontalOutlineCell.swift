//
//  WRPDFHorizontalOutlineCell.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WRPDFModel

class WRPDFHorizontalOutlineCell: UICollectionViewCell {
    
    fileprivate var titleLabel: UILabel!
    fileprivate var titleLabel_leading: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initUI()
    }
    
    fileprivate func initUI() {
        titleLabel = UILabel()
        self.addSubview(titleLabel)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = WRPDFReaderConfig.shared.outlineColor
        
        self.titleLabel_leading = NSLayoutConstraint(item: titleLabel!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 30)

        self.addConstraints([
            self.titleLabel_leading!,
            NSLayoutConstraint(item: titleLabel!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleLabel!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleLabel!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        ])
        
        let line = UIView()
        self.addSubview(line)
        line.backgroundColor = WRPDFReaderConfig.shared.outlineLineColor
        line.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: line, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: line, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: line, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
        line.addConstraint(NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConfig(_ outline: WROutline) {
        self.titleLabel_leading?.constant = CGFloat(outline.level * 30)
        self.titleLabel.text = outline.title
    }
    
    func setConfig(_ value: (Int, String)) {
        self.titleLabel.text = value.1

    }
}
