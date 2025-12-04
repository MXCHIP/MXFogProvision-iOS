//
//  MXAccountModel.swift
//  LSApp
//
//  Created by huafeng on 2025/3/28.
//

import Foundation

class MXAccountModel: NSObject {
    
    // singleton
    static let shared = MXAccountModel()
    
    func getLanguageVariants(_ identifier: String) -> [String] {
        let components = Locale.components(fromIdentifier: identifier)
        let langCode = components[NSLocale.Key.languageCode.rawValue] ?? ""
        let scriptCode = components[NSLocale.Key.scriptCode.rawValue] ?? ""
        
        var variants = [identifier]
        if !scriptCode.isEmpty {
            variants.append("\(langCode)-\(scriptCode)") // 如 "zh-Hans"
        }
        variants.append(langCode) // 如 "zh"
        return variants
    }
    
    func getLanguageCodeWithoutRegion(_ identifier: String) -> String {
        let components = Locale.components(fromIdentifier: identifier)
        let langCode = components[NSLocale.Key.languageCode.rawValue] ?? ""
        let scriptCode = components[NSLocale.Key.scriptCode.rawValue] ?? ""
        return scriptCode.isEmpty ? langCode : "\(langCode)-\(scriptCode)"
    }
    
    func getLocalizableLanguages() -> [String] {
        let allLangs = Bundle.main.localizations
        var uniqueLangs = Set<String>()
        
        allLangs.forEach { identifier in
            guard identifier != "Base" else { return }
            let components = Locale.components(fromIdentifier: identifier)
            let lang = components[NSLocale.Key.languageCode.rawValue] ?? ""
            let script = components[NSLocale.Key.scriptCode.rawValue] ?? ""
            let code = script.isEmpty ? lang : "\(lang)-\(script)"
            if !code.isEmpty {
                uniqueLangs.insert(code)
            }
        }
        return Array(uniqueLangs).sorted()
    }
    
    var language : String {
        get {
            if let lang = UserDefaults.standard.string(forKey: "MXAppCurrentLanguage") {
                return lang
            }
            let appLanguages = getLocalizableLanguages()
            guard let systemLang = Locale.preferredLanguages.first else {
                return "en"
            }
            let pureCode = getLanguageCodeWithoutRegion(systemLang)
            if appLanguages.contains(pureCode) {
                return pureCode
            }
            return "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MXAppCurrentLanguage")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MXNotificationAppLanguageChange"), object: nil)
        }
    }
}
