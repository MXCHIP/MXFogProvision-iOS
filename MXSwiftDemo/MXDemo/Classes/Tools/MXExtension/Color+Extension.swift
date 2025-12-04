//
//  Color+Extension.swift
//  MXDemo
//
//  Created for SwiftUI Color Support
//

import SwiftUI

extension Color {
    /// 从十六进制字符串创建Color
    init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexValue = hexValue.replacingOccurrences(of: "#", with: "")
        
        guard hexValue.count == 6 || hexValue.count == 8 else {
            self.init(red: 0, green: 0, blue: 0, opacity: alpha)
            return
        }
        
        var hexNumber: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&hexNumber)
        
        if hexValue.count == 8 {
            self.init(
                red: Double((hexNumber & 0xff000000) >> 24) / 255,
                green: Double((hexNumber & 0x00ff0000) >> 16) / 255,
                blue: Double((hexNumber & 0x0000ff00) >> 8) / 255,
                opacity: Double(hexNumber & 0x000000ff) / 255
            )
        } else {
            self.init(
                red: Double((hexNumber & 0xff0000) >> 16) / 255,
                green: Double((hexNumber & 0x00ff00) >> 8) / 255,
                blue: Double(hexNumber & 0x000000ff) / 255,
                opacity: alpha
            )
        }
    }
}

// SwiftUI版本的MXColor配置
extension MXAppConfig {
    struct MXSwiftUIColor {
        static var background: Color {
            return Color(hex: "E8E7DB")
        }
        
        static var buttonSelectedBG: Color {
            return Color(hex: "262D2D")
        }
        
        static var buttonNormalBG: Color {
            return Color(hex: "F6F6F1")
        }
        
        static var titleColor: Color {
            return Color(hex: "262D2D")
        }
        
        static var placeholderColor: Color {
            return Color(hex: "C1C0BA")
        }
        
        static var secondColor: Color {
            return Color(hex: "8A8D8C")
        }
        
        static var border: Color {
            return Color(hex: "EEEEEE")
        }
    }
}

