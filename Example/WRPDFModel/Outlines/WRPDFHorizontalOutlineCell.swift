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
    fileprivate var pageLabel: UILabel!
    fileprivate var pageLabel_width: NSLayoutConstraint!

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
        
        pageLabel = UILabel()
        self.addSubview(pageLabel)
        pageLabel.backgroundColor = .clear
        pageLabel.font = UIFont.systemFont(ofSize: 18)
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.textColor = WRPDFReaderConfig.shared.outlineColor
        
        do {
            addConstraints([
                NSLayoutConstraint(item: pageLabel!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20),
                NSLayoutConstraint(item: pageLabel!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: pageLabel!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
            ])
            pageLabel_width = NSLayoutConstraint(item: pageLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 10)
            pageLabel.addConstraint(pageLabel_width)
        }

        addConstraints([
            self.titleLabel_leading!,
            NSLayoutConstraint(item: titleLabel!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleLabel!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleLabel!, attribute: .trailing, relatedBy: .equal, toItem: pageLabel, attribute: .leading, multiplier: 1.0, constant: -10)
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
        
        pageLabel.text = "\(outline.page)"
        guard let text = pageLabel.text else {
            return
        }
        pageLabel_width.constant = ceil((text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [.font : pageLabel.font!], context: nil).width)

    }
    
    func setConfig(_ value: (Int, String), search text: String) {
        let resultString = value.1
        
        let attribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : WRPDFReaderConfig.shared.outlineColor]
        let attributedString = NSMutableAttributedString(string: resultString, attributes: attribute)
        
        let range = (resultString as NSString).range(of: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = range.location >= ((resultString as NSString).length / 2) ? .byTruncatingHead : .byTruncatingTail
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, (resultString as NSString).length))
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.yellow], range: range)

        self.titleLabel.attributedText = attributedString
        pageLabel.text = "\(value.0)"
        guard let text = pageLabel.text else {
            return
        }
        pageLabel_width.constant = ceil((text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [.font : pageLabel.font!], context: nil).width)
    }
}
