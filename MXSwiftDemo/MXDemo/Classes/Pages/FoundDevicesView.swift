//
//  FoundDevicesView.swift
//  MXDemo
//
//  SwiftUI版本发现设备页面
//

import SwiftUI
import MXFogProvision

struct FoundDevicesView: View {
    @State private var dataList: [MXProvisionDeviceInfo] = []
    @State private var headerText: String?
    @State private var showNextButton = false
    @State private var navigateToProvision = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景色
            MXAppConfig.MXSwiftUIColor.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 头部提示文字
                if let headerText = headerText {
                    Text(headerText)
                        .font(.system(size: 14))
                        .foregroundColor(MXAppConfig.MXSwiftUIColor.secondColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                }
                
                // 设备列表
                ScrollView {
                    FlowLayout(spacing: 12) {
                        ForEach(dataList.indices, id: \.self) { index in
                            FoundDeviceCellView(device: dataList[index]) {
                                toggleDeviceSelection(at: index)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                
                Spacer()
                
                // 底部按钮
                HStack(spacing: 12) {
                    if showNextButton {
                        Button(action: {
                            reSearch()
                        }) {
                            HStack {
                                Image("mx_refresh")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Re-search")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(MXAppConfig.MXSwiftUIColor.titleColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 49)
                            .background(Color.white)
                            .cornerRadius(24.5)
                        }
                        
                        Button(action: {
                            nextAction()
                        }) {
                            HStack {
                                Image("mx_selected")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Next")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 49)
                            .background(MXAppConfig.MXSwiftUIColor.buttonSelectedBG)
                            .cornerRadius(24.5)
                        }
                    } else {
                        Button(action: {
                            reSearch()
                        }) {
                            HStack {
                                Image("mx_refresh")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Re-search")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(MXAppConfig.MXSwiftUIColor.titleColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 49)
                            .background(Color.white)
                            .cornerRadius(24.5)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .navigationTitle("Found Devices")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("mx_back")
                        .renderingMode(.template)
                        .foregroundColor(MXAppConfig.MXSwiftUIColor.titleColor)
                }
            }
        }
        .onAppear {
            startScanDevice()
        }
        .onDisappear {
            MXFogBleScan.shared.stopScan()
        }
        .navigationDestination(isPresented: $navigateToProvision) {
            if let selectedDevices = getSelectedDevices() {
                DevicesProvisionView(dataList: selectedDevices)
            }
        }
    }
    
    // MARK: - 扫描设备
    func startScanDevice() {
        MXFogBleScan.shared.stopScan()
        dataList.removeAll()
        showNextButton = false
        headerText = nil
        
        MXFogBleScan.shared.startScan { devices, isStop in
            var newList: [MXProvisionDeviceInfo] = []
            devices.forEach { (info: [String: Any]) in
                let deviceInfo = MXProvisionDeviceInfo(params: info)
                if let pk = deviceInfo.productKey,
                   let dn = deviceInfo.deviceName {
                    newList.append(deviceInfo)
                    if dataList.first(where: { $0.productKey == pk && $0.deviceName == dn }) == nil {
                        dataList.append(deviceInfo)
                    }
                }
            }
            
            // 移除不在新列表中的设备
            dataList.removeAll { device in
                newList.first(where: { $0.productKey == device.productKey && $0.deviceName == device.deviceName }) == nil
            }
            
            DispatchQueue.main.async {
                if dataList.count > 0 {
                    headerText = String(format: "%d devices found, please make a selection...", dataList.count)
                } else {
                    headerText = nil
                }
                updateNextButtonVisibility()
            }
        }
    }
    
    // MARK: - 切换设备选择状态
    func toggleDeviceSelection(at index: Int) {
        guard index < dataList.count else { return }
        dataList[index].isSelected.toggle()
        updateNextButtonVisibility()
    }
    
    // MARK: - 更新Next按钮显示状态
    func updateNextButtonVisibility() {
        showNextButton = dataList.contains(where: { $0.isSelected })
    }
    
    // MARK: - 重新搜索
    func reSearch() {
        startScanDevice()
    }
    
    // MARK: - 获取选中的设备
    func getSelectedDevices() -> [MXProvisionDeviceInfo]? {
        let selectedDevices = dataList.filter { $0.isSelected }
        return selectedDevices.count > 0 ? selectedDevices : nil
    }
    
    // MARK: - 下一步操作
    func nextAction() {
        let selectedDevices = dataList.filter { $0.isSelected }
        guard selectedDevices.count > 0 else { return }
        navigateToProvision = true
    }
}

// MARK: - 发现设备Cell视图
struct FoundDeviceCellView: View {
    let device: MXProvisionDeviceInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 0) {
                Image("mx_ble_icon")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(device.isSelected ? .white : MXAppConfig.MXSwiftUIColor.titleColor)
                    .padding(.leading, 12)
                
                Text(device.name ?? "Unknown Device")
                    .font(.system(size: 14))
                    .foregroundColor(device.isSelected ? .white : MXAppConfig.MXSwiftUIColor.titleColor)
                    .padding(.leading, 0)
                    .padding(.trailing, 12)
                    .frame(height: 40)
            }
            .background(device.isSelected ? MXAppConfig.MXSwiftUIColor.buttonSelectedBG : MXAppConfig.MXSwiftUIColor.buttonNormalBG)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FlowLayout布局（用于流式布局，iOS 16+）
@available(iOS 16.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // 换行
                    currentY += lineHeight + spacing
                    currentX = 0
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

