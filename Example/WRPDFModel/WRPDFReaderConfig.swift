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
    @objc open var showSearchItem: Bool = true

    @objc open var darkColor: UIColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    @objc open var lightColor: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    
    @objc open var navigationBarDarkColor: UIColor = UIColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1)
    @objc open var navigationBarLightColor: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)

    @objc open var navigationBarDarkTintColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    @objc open var navigationBarLightTintColor: UIColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1)

    
    internal var backgroundColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.darkColor : WRPDFReaderConfig.shared.lightColor
    }

    internal var navigationBarColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.navigationBarDarkColor : WRPDFReaderConfig.shared.navigationBarLightColor
    }
    
    internal var navigationTintColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.navigationBarDarkTintColor : WRPDFReaderConfig.shared.navigationBarLightTintColor
    }


    public static let shared : WRPDFReaderConfig = {
        let manager = WRPDFReaderConfig()
        return manager
    }()


}
