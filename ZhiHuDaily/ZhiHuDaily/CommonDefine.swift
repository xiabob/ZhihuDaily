//
//  CommonDefine.swift
//  ZhiHuDaily
//
//  Created by xiabob on 17/3/17.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import Foundation
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

//MARK: - 基本属性
let kScreenBounds = UIScreen.main.bounds

// 屏幕的物理宽度
let kScreenWidth = UIScreen.main.bounds.size.width
// 屏幕的物理高度
let kScreenHeight = UIScreen.main.bounds.size.height

let kScreenScale = UIScreen.main.scale

let kStatusBarHeight: CGFloat = 20
let kNavigationBarHeight: CGFloat = 44
let kTabBarHeight: CGFloat = 49

let kXBBorderWidth = (1.0 / kScreenScale)

let kIsIOS7: Bool =  {
    return (UIDevice.current.systemVersion as NSString).doubleValue >= 7.0
}()

let kIsIOS8: Bool = {
    return (UIDevice.current.systemVersion as NSString).doubleValue >= 8.0
}()

var kIOSVersionValue: Double {
    return (UIDevice.current.systemVersion as NSString).doubleValue
}

// RGBA的颜色设置
func kRGBA(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}


//MARK: - Color

let kMenuBackgroundColor = UIColor(red:0.14, green:0.16, blue:0.19, alpha:1)
let kMenuSelectedColor = UIColor(red:0.1, green:0.14, blue:0.16, alpha:1)
let kLaunchBackgroundColor = kRGBA(20, g: 20, b: 20, a: 1)
let kMainNavigationBarColor = UIColor(red:0.01, green:0.56, blue:0.84, alpha:1)
let kXBBorderColor = kRGBA(227, g: 227, b: 227, a: 1.0)
let kMenuGrayWhiteTextColor = UIColor(red:0.54, green:0.56, blue:0.58, alpha:1)




