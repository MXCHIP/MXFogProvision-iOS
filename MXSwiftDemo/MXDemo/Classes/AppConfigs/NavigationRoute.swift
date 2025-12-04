//
//  NavigationRoute.swift
//  LSApp
//
//  Created for SwiftUI Navigation
//

import Foundation

// 用于存储配网路由数据的结构体
struct ProvisionRouteData: Hashable {
    let networkKey: String?
    let deviceUUIDs: [String]
    
    static func == (lhs: ProvisionRouteData, rhs: ProvisionRouteData) -> Bool {
        return lhs.networkKey == rhs.networkKey && lhs.deviceUUIDs == rhs.deviceUUIDs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(networkKey)
        hasher.combine(deviceUUIDs)
    }
}

enum NavigationRoute: Hashable {
    case devices
    case foundDevices
    case provision(ProvisionRouteData)
}

