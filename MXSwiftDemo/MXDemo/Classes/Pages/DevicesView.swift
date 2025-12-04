//
//  DevicesView.swift
//  MXDemo
//
//  SwiftUI版本设备列表页面
//

import SwiftUI

struct DevicesView: View {
    @State private var deviceList: [MXDeviceInfo] = []
    @State private var selectedDevice: MXDeviceInfo?
    
    var body: some View {
        ZStack {
            // 背景色
            MXAppConfig.MXSwiftUIColor.background
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(deviceList.indices, id: \.self) { index in
                        DeviceCellView(device: deviceList[index]) { device in
                            
                        } onLongPress: { device in
                            selectedDevice = device
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("My Devices")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: FoundDevicesView()) {
                    Image("mx_search")
                        .renderingMode(.template)
                        .foregroundColor(MXAppConfig.MXSwiftUIColor.titleColor)
                }
            }
        }
        .onAppear {
            requestData()
        }
    }
    
    // MARK: - 数据请求
    func requestData() {
        deviceList = MXDeviceManager.shard.loadDevices()
    }
}

// MARK: - 设备Cell视图
struct DeviceCellView: View {
    let device: MXDeviceInfo
    let onSwitch: (MXDeviceInfo) -> Void
    let onLongPress: (MXDeviceInfo) -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(device.name ?? "Unknown Device")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(device.isOnline ? MXAppConfig.MXSwiftUIColor.titleColor : Color(hex: "999999"))
                
                HStack(spacing: 4) {
                    Image(device.isOnline ? "mx_connect" : "mx_disconnect")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text(device.isOnline ? "Connect" : "Disconnect")
                        .font(.system(size: 14))
                        .foregroundColor(device.isOnline ? MXAppConfig.MXSwiftUIColor.secondColor : Color(hex: "999999"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
        }
        .frame(height: 76)
        .background(backgroundColor)
        .cornerRadius(10)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 1.0) {
            onLongPress(device)
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
    
    private var isSwitchOn: Bool {
        return true
    }
    
    private var backgroundColor: Color {
        if isPressed {
            return Color.gray.opacity(0.3)
        }
        
        if !device.isOnline {
            return Color(hex: "C1C0BA")
        }
        
        if isSwitchOn {
            return .white
        } else {
            return Color(hex: "F6F6F1")
        }
    }
}

