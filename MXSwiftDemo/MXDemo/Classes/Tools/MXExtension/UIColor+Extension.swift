//
//  UIColor+Extension.swift
//  MXApp
//
//  Created by huafeng on 2024/9/6.
//

import Foundation
import UIKit


extension UIColor {
    
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
    /// 十六进制初始化（支持字符串和整型）
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexValue = hexValue.replacingOccurrences(of: "#", with: "")

        guard hexValue.count == 6 || hexValue.count == 8 else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }

        let scanner = Scanner(string: hexValue)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }

        if hexValue.count == 8 {
            self.init(
                red: CGFloat((hexNumber & 0xff000000) >> 24) / 255,
                green: CGFloat((hexNumber & 0x00ff0000) >> 16) / 255,
                blue: CGFloat((hexNumber & 0x0000ff00) >> 8) / 255,
                alpha: CGFloat(hexNumber & 0x000000ff) / 255
            )
        } else {
            self.init(
                red: CGFloat((hexNumber & 0xff0000) >> 16) / 255,
                green: CGFloat((hexNumber & 0x00ff00) >> 8) / 255,
                blue: CGFloat(hexNumber & 0x0000ff) / 255,
                alpha: alpha
            )
        }
    }

    /// 整型十六进制初始化
    convenience init(hexInt: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hexInt >> 16) & 0xFF) / 255,
            green: CGFloat((hexInt >> 8) & 0xFF) / 255,
            blue: CGFloat(hexInt & 0xFF) / 255,
            alpha: alpha
        )
    }
    
    convenience init(with lightModeHex: String,
                     lightModeAlpha: CGFloat,
                     darkModeHex: String,
                     darkModeAlpha : CGFloat) {
        
        self.init { (trait: UITraitCollection) in
            if trait.userInterfaceStyle == .light {
                return UIColor(hex: lightModeHex, alpha: lightModeAlpha)
            } else {
                return UIColor(hex: darkModeHex, alpha: darkModeAlpha)
            }
        }
    }
    
}
