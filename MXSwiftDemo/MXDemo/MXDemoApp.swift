//
//  MXDemoApp.swift
//  MXDemo
//
//  Created for SwiftUI App
//

import SwiftUI

@main
struct MXDemoApp: App {
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            DevicesView()
        }
    }
}

