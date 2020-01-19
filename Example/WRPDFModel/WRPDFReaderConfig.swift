//
//  WRPDFReaderConfig.swift
//  WRPDFModel_Example
//
//  Created by 项辉 on 2020/1/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

open class WRPDFReaderConfig: NSObject {
        
    enum Notify: Int {
        case dark

        var name : Notification.Name {
            return Notification.Name("WRPDFReaderConfig_Notify_\(self.rawValue)")
        }
    }

    @objc open var isDark: Bool = false {
        didSet {
            NotificationCenter.default.post(name: WRPDFReaderConfig.Notify.dark.name, object: self.isDark)
        }
        

    }
    
    @objc open var hasAnimated: Bool = false
    
    @objc open var isTiled: Bool = false
    @objc open var darkColor: UIColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    @objc open var lightColor: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    
    internal var backgroundColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.darkColor : WRPDFReaderConfig.shared.lightColor
    }

    public static let shared : WRPDFReaderConfig = {
        let manager = WRPDFReaderConfig()
        return manager
    }()


}
