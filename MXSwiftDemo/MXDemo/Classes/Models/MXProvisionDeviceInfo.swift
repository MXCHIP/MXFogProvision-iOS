
import Foundation
import CoreBluetooth

public class MXProvisionDeviceInfo: NSObject {
    
    public var name: String?
    
    public var mac: String?
    public var deviceName: String?
    public var productKey: String?
    
    public var peripheral: CBPeripheral?
    
    public var provisionStatus : Int = 0
    public var firmware_version : String?
    
    public var isSelected: Bool = false
    
    public var timeStamp : TimeInterval = Date().timeIntervalSince1970
    var provisionError: String?
    
    public override init() {
        super.init()
    }
    
    convenience init(params:[String: Any]) {
        self.init()
        self.name = params["name"] as? String
        self.peripheral = params["peripheral"] as? CBPeripheral
        self.mac = params["mac"] as? String
        self.deviceName = params["deviceName"] as? String
        if let pk = params["productId"] as? String {
            self.productKey = pk
        } else if let pk = params["productKey"] as? String {
            self.productKey = pk
        }
        
        if let deviceName = self.deviceName {
            self.name = (self.name ?? "") + " " + deviceName
        }
    }
}
