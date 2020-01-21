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

    /**配置暗黑模式*/
    /**
    默认白天
    */
    @objc open var isDark: Bool = false {
        didSet {
            NotificationCenter.default.post(name: WRPDFReaderConfig.Notify.dark.name, object: self.isDark)
        }
    }
    
    /**是否展示 UIPageViewController 的 pageCurl 动画*/
    @objc open var hasAnimated: Bool = false
    /**是否展示搜索按钮*/
    @objc open var showSearchItem: Bool = false

    /**视图的背景色*/
    /**
    暗黑
    */
    @objc open var darkColor: UIColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    /**视图的背景色*/
    /**
    白天
    */
    @objc open var lightColor: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    
    /**导航条背景色*/
    /**
    暗黑
    */
    @objc open var navigationBarDarkColor: UIColor = UIColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1)
    /**导航条背景色*/
    /**
    白天
    */
    @objc open var navigationBarLightColor: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)

    /**导航条Tint颜色*/
    /**
    暗黑
    */
    @objc open var navigationBarDarkTintColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    /**导航条Tint颜色*/
    /**
    白天
    */
    @objc open var navigationBarLightTintColor: UIColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1)

    /**目录颜色*/
    /**
    暗黑
    */
    @objc open var outlineDarkColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    /**目录颜色*/
    /**
    白天
    */
    @objc open var outlineLightColor: UIColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)

    /**目录分割线颜色*/
    @objc open var outlineLineColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    
    /**返回按钮图片*/
    @objc public var backImage: UIImage?
    /**返回按钮标题*/
    @objc public var backTitle: String?
    
    /**目录按钮图片*/
    @objc public var outlinesImage: UIImage?
    /**目录按钮标题*/
    @objc public var outlinesTitle: String?
    
    /**搜索按钮图片*/
    @objc public var searchImage: UIImage?
    /**搜索按钮标题*/
    @objc public var searchTitle: String?

    /**菜单按钮图片*/
    @objc public var menuImage: UIImage?
    /**菜单按钮标题*/
    @objc public var menuTitle: String?

    /**搜索结果数*/
    @objc public var searchResultTitle: String? = "搜索结果："
    /**搜索结果数*/
    @objc func searchResult(_ count: Int) -> String {
        return (searchResultTitle ?? "")  + "\(count)"
    }
    

    internal var backgroundColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.darkColor : WRPDFReaderConfig.shared.lightColor
    }

    internal var navigationBarColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.navigationBarDarkColor : WRPDFReaderConfig.shared.navigationBarLightColor
    }
    
    internal var navigationTintColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.navigationBarDarkTintColor : WRPDFReaderConfig.shared.navigationBarLightTintColor
    }

    internal var outlineColor: UIColor {
        return WRPDFReaderConfig.shared.isDark ? WRPDFReaderConfig.shared.outlineDarkColor : WRPDFReaderConfig.shared.outlineLightColor
    }

    /**PDF阅读器配置*/
    public static let shared : WRPDFReaderConfig = {
        let manager = WRPDFReaderConfig()
        return manager
    }()


}
