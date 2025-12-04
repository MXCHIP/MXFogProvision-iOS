//
//  MXAppConfig.swift
//  LSApp
//
//  Created by huafeng on 2025/2/21.
//

import Foundation
import UIKit

class MXAppConfig: NSObject {
    public static var statusBarH : CGFloat {
        get {
            if #available(iOS 13.0, *) {
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                return scene?.statusBarManager?.statusBarFrame.size.height ?? 44
            } else {
                // 在iOS 13以下版本中，可以直接使用statusBarFrame
                return UIApplication.shared.statusBarFrame.size.height
            }
        }
    }
    public static var bottomSafeH: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.windows.first
                return window?.safeAreaInsets.bottom ?? 0
            }
            return 0
        }
    }

    public static let navBarH : CGFloat = 44.0
    public static let screenWidth = UIScreen.main.bounds.size.width
    public static let screenHeight = UIScreen.main.bounds.size.height
    
    public static let mxAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    public static let provisionQueueMax = 1

    public static func mxLocalized(key: String) -> String {
        let currentLang = MXAccountModel.shared.language
        if let langPath = Bundle.main.path(forResource: currentLang, ofType: "lproj"),
           let langBundle = Bundle.init(path: langPath)  {
            return langBundle.localizedString(forKey: key, value: nil, table: "Localizable")
        }
        return NSLocalizedString(key, comment: "")
    }
    
    struct MXColor {
        static var background: UIColor  {
            return UIColor(hex: "E8E7DB")
        }
        
        static var buttonSelectedBG: UIColor  {
            return UIColor(hex: "262D2D")
        }
        
        static var buttonNormalBG: UIColor  {
            return UIColor(hex: "F6F6F1")
        }
        
        static var titleColor: UIColor  {
            return UIColor(hex: "262D2D")
        }
        
        static var placeholderColor: UIColor  {
            return UIColor(hex: "C1C0BA")
        }
        
        static var secondColor: UIColor  {
            return UIColor(hex: "8A8D8C")
        }
        
        /// EEEEEE
        static var border: UIColor  {
            return UIColor(hex: "EEEEEE")
        }
    }
    
}
