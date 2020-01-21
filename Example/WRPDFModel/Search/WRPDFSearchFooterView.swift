//
//  WRPDFSearchFooterView.swift
//  WRPDFModel_Example
//
//  Created by xianghui-iMac on 2020/1/21.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class WRPDFSearchFooterView: UICollectionReusableView {
      
    var resultLabel: UILabel!
    var pageCountLabel: UILabel!
    var pageCountLabel_width: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = WRPDFReaderConfig.shared.backgroundColor
        layer.shadowColor = WRPDFReaderConfig.shared.outlineLineColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -0.5)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 1

        resultLabel = UILabel()
        addSubview(resultLabel)
        resultLabel.backgroundColor = .clear
        resultLabel.textColor = WRPDFReaderConfig.shared.outlineColor
        resultLabel.font = UIFont.systemFont(ofSize: 17)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pageCountLabel = UILabel()
        addSubview(pageCountLabel)
        pageCountLabel.backgroundColor = .clear
        pageCountLabel.textColor = WRPDFReaderConfig.shared.outlineColor
        pageCountLabel.font = UIFont.systemFont(ofSize: 17)
        pageCountLabel.translatesAutoresizingMaskIntoConstraints = false

        do {
            addConstraints([
                NSLayoutConstraint(item: resultLabel!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20),
                NSLayoutConstraint(item: resultLabel!, attribute: .trailing, relatedBy: .equal, toItem: self.pageCountLabel, attribute: .leading, multiplier: 1.0, constant: -10),
                NSLayoutConstraint(item: resultLabel!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: resultLabel!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
            ])
        }

        do {
            addConstraints([
                NSLayoutConstraint(item: pageCountLabel!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20),
                NSLayoutConstraint(item: pageCountLabel!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: pageCountLabel!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
            ])
            pageCountLabel_width = NSLayoutConstraint(item: pageCountLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 10)
            pageCountLabel.addConstraint(pageCountLabel_width)
        }
    }
    
    func setConfig(result: String, pageCount: String) {
        resultLabel.text = result
        pageCountLabel.text = pageCount
        pageCountLabel_width.constant = ceil((pageCount as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [.font : pageCountLabel.font!], context: nil).width)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
