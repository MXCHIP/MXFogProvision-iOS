//
//  DevicesProvisionView.swift
//  MXDemo
//
//  SwiftUI版本设备配网页面
//

import SwiftUI
import MXFogProvision

struct DevicesProvisionView: View {
    let dataList: [MXProvisionDeviceInfo]
    
    @State private var provisionList: [MXProvisionDeviceInfo] = []
    @State private var showNextButton = false
    @State private var showReconnectButton = false
    @State private var provisionDelegate: ProvisionDelegate?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景色
            MXAppConfig.MXSwiftUIColor.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 设备列表
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(provisionList.indices, id: \.self) { index in
                            ProvisionDeviceCellView(device: provisionList[index])
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                
                Spacer()
                
                // 底部按钮
                HStack(spacing: 12) {
                    if showReconnectButton {
                        Button(action: {
                            refreshProvision()
                        }) {
                            HStack {
                                Image("mx_refresh")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Re-connect")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(MXAppConfig.MXSwiftUIColor.titleColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 49)
                            .background(Color.white)
                            .cornerRadius(24.5)
                        }
                    }
                    
                    if showNextButton {
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
                            .frame(maxWidth: showReconnectButton ? .infinity : .infinity)
                            .frame(height: 49)
                            .background(MXAppConfig.MXSwiftUIColor.buttonSelectedBG)
                            .cornerRadius(24.5)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .navigationTitle("My Devices")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            provisionList = dataList
            startProvisionDevice()
            // 配网过程中不允许左滑返回和自动熄屏
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            MXFogBleProvision.shared.cleanProvisionCache()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // MARK: - 开始配网
    func startProvisionDevice() {
        let unProvisionList = provisionList.filter { $0.provisionStatus == 0 }
        let provisioningList = provisionList.filter { $0.provisionStatus == 1 }
        
        if unProvisionList.count > 0 {
            for item in unProvisionList {
                if provisioningList.count < MXAppConfig.provisionQueueMax {
                    item.provisionStatus = 1
                    startBleProvision(info: item)
                    startProvisionDevice()
                    return
                }
            }
        } else {
            if provisionList.first(where: { $0.provisionStatus == 1 }) == nil {
                showNextButton = true
                showReconnectButton = provisionList.contains(where: { $0.provisionStatus == 3 })
            } else {
                showNextButton = false
                showReconnectButton = false
            }
        }
    }
    
    // MARK: - 配网失败
    func provisionFail(productKey: String?, deviceName: String?) {
        if let pk = productKey,
           let dn = deviceName,
           let index = provisionList.firstIndex(where: { $0.productKey == pk && $0.deviceName == dn }) {
            provisionList[index].provisionStatus = 3
        }
        startProvisionDevice()
    }
    
    // MARK: - 配网成功
    func provisionSuccess(productKey: String?, deviceName: String?) {
        guard let pk = productKey,
              let dn = deviceName,
              let index = provisionList.firstIndex(where: { $0.productKey == pk && $0.deviceName == dn }) else {
            startProvisionDevice()
            return
        }
        
        provisionList[index].provisionStatus = 2
        startProvisionDevice()
    }
    
    // MARK: - 绑定设备
    func bindDevice(info: MXProvisionDeviceInfo) {
        let device = MXDeviceInfo()
        device.name = info.name
        device.productKey = info.productKey
        device.firmware_version = info.firmware_version
        device.deviceName = info.deviceName
        device.mac = info.mac
        
        MXDeviceManager.shard.add(device: device)
        device.bindTime = Int(Date().timeIntervalSince1970)
        provisionSuccess(productKey: info.productKey, deviceName: info.deviceName)
    }
    
    // MARK: - 开始Mesh配网
    func startBleProvision(info: MXProvisionDeviceInfo) {
        
        let delegate = ProvisionDelegate { pk, dn, error in
            guard let index = provisionList.firstIndex(where: { $0.productKey == pk && $0.deviceName == dn }) else {
                return
            }
            if error == nil {
                bindDevice(info: provisionList[index])
            } else {
                provisionList[index].provisionError = error?.domain
                provisionFail(productKey: pk, deviceName: dn)
            }
        }
        
        provisionDelegate = delegate
        if let dn = info.deviceName, let pk = info.productKey {
            MXFogBleProvision.shared.provisionDevice(peripheral: info.peripheral, productKey: pk, deviceName: dn, delegate: delegate)
        }
    }
    
    // MARK: - 刷新配网
    func refreshProvision() {
        provisionList.forEach { device in
            if device.provisionStatus == 3 {
                device.provisionStatus = 0
            }
        }
        startProvisionDevice()
    }
    
    // MARK: - 下一步操作
    func nextAction() {
        // 返回根视图
        dismiss()
    }
}

// MARK: - 配网代理
class ProvisionDelegate: NSObject, MXFogProvisionDelegate {
    
    var requestNum: Int = 0
    
    public var provisionFinishHandler: (String, String, NSError?) -> Void
    
    init(provisionFinishHandler: @escaping (String, String, NSError?) -> Void) {
        self.provisionFinishHandler = provisionFinishHandler
    }
    /*
     请求随机数,一般由云端实现，可以不实现这个delegate func,不实现func，内部会自动生成
     @params productKey
     @params deviceName
     @result: String?
     */
    @objc func mxFogProvisionRequestRandom(productKey:String?,
                                           deviceName: String?,
                                           handler: @escaping (String?) -> Void) {
        //模拟调用SDK内部实现的func生成随机数传入
        if let randomStr = MXFogBleProvision.shared.createRandom() {
            handler(randomStr)
        }
    }
    /*
     请求ble加密密钥，一般由云端实现
     @params productKey
     @params deviceName
     @params random
     @params cipher
     @result: String?
    */
    @objc func mxFogProvisionRequestBleKey(productKey:String?,
                                           deviceName: String?,
                                           random: String?,
                                           cipher: String?,
                                           handler: @escaping (String?) -> Void) {
        //模拟实现本地存储了设备信息，通过deviceSecret生成bleKey
        //通过productKey & deviceName，找到设备的ds
        let ds = "ac99f9066b51b9ed3885db9dabd7e380"
        if let bleKey = MXFogBleProvision.shared.createBleKey(secret: ds) {
            handler(bleKey)
        }
    }
    /*输入Wi-Fi信息
     @params productKey
     @params deviceName
     @callback  ssid
     @callback  password
     @callback  customParams [String: Any]  [mqttURL: String, httpURL: String]
    */
    @objc func mxFogProvisionInputWifiInfo(productKey:String?,
                                           deviceName: String?,
                                           handler: @escaping (String, String?, [String : Any]?) -> Void) {
        self.requestNum = 0
        var customParams = [String: Any]()
        customParams["mqtturl"] = "app.api.fogcloud.io"
        customParams["httpurl"] = "app.mqtt.fogcloud.io"
        handler("AP106", "12345678", customParams)
    }
    /*
     配网结束
     @params productKey
     @params deviceName
     @params error
     */
    @objc func mxFogProvisionFinish(productKey:String?,
                                    deviceName: String?,
                                    error: NSError?) {
        print("配网结束：\(String(describing: error))")
        guard let pk = productKey, let dn = deviceName else {
            return
        }
        self.provisionFinishHandler(pk, dn, error)
    }
    /*
     云端轮训设备连接状态
     @params productKey
     @params deviceName
     @params random
    */
    @objc func mxFogProvisionRequestConnectStatus(productKey:String?,
                                                  deviceName: String?,
                                                  random: String?,
                                                  handler: @escaping (Bool) -> Void) {
        //模拟轮询3次之后，设备连接成功
        self.requestNum += 1
        if self.requestNum > 3 {
            handler(true)
        } else {
            handler(false)
        }
    }
}

// MARK: - 配网设备Cell视图
struct ProvisionDeviceCellView: View {
    let device: MXProvisionDeviceInfo
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        HStack(spacing: 0) {
            Image("mx_ble_icon")
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(MXAppConfig.MXSwiftUIColor.titleColor)
                .padding(.leading, 12)
            
            Text(device.name ?? "Unknown Device")
                .font(.system(size: 14))
                .foregroundColor(MXAppConfig.MXSwiftUIColor.titleColor)
                .padding(.leading, 0)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            statusImage
                .frame(width: 24, height: 24)
                .padding(.trailing, 12)
        }
        .frame(height: 76)
        .background(backgroundColor)
        .cornerRadius(10)
        .onChange(of: device.provisionStatus) { _ in
            if device.provisionStatus == 1 {
                startRotation()
            } else {
                stopRotation()
            }
        }
        .onAppear {
            if device.provisionStatus == 1 {
                startRotation()
            }
        }
    }
    
    @ViewBuilder
    private var statusImage: some View {
        switch device.provisionStatus {
        case 1:
            Image("mx_icon_loading")
                .resizable()
                .rotationEffect(.degrees(rotationAngle))
        case 2:
            Image("mx_icon_success")
                .resizable()
        case 3:
            Image("mx_icon_fail")
                .resizable()
        default:
            EmptyView()
        }
    }
    
    private var backgroundColor: Color {
        if device.provisionStatus == 3 {
            return Color(hex: "F6F6F1")
        }
        return .white
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func stopRotation() {
        withAnimation {
            rotationAngle = 0
        }
    }
}

