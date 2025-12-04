
import Foundation

public class MXDeviceInfo: NSObject, Codable {
    public var name: String?
    public var image: String?
    public var productKey: String?
    public var deviceName: String?
    public var firmware_version : String?  
    public var bindTime: Int = 0
    
    public var isOnline: Bool = true
    
    public var isSelected: Bool = false
    
    public var mac: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case name
        case image
        case productKey
        case deviceName
        case firmware_version
        case bindTime
        case mac
    }
    
    
    public func isSameFrom(_ device:MXDeviceInfo?) -> Bool {
        guard let device = device else {
             return false
        }

       if let dn = self.deviceName,
          dn == device.deviceName,
          self.productKey == device.productKey {
            return true
        }
        return false
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXDeviceInfo else {
            return false
        }
        return (self.name == obj.name &&
                self.image == obj.image &&
                self.deviceName == obj.deviceName &&
                self.productKey == obj.productKey)
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.productKey = try container.decodeIfPresent(String.self, forKey: .productKey)
        self.deviceName = try container.decodeIfPresent(String.self, forKey: .deviceName)
        
        self.firmware_version = try container.decodeIfPresent(String.self, forKey: .firmware_version)
        self.bindTime = (try? container.decode(Int.self, forKey: .bindTime)) ?? 0
        
        self.mac = try container.decodeIfPresent(String.self, forKey: .mac)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(image, forKey: .image)
        
        try container.encodeIfPresent(productKey, forKey: .productKey)
        try container.encodeIfPresent(deviceName, forKey: .deviceName)
        try container.encodeIfPresent(mac, forKey: .mac)
        
        try container.encodeIfPresent(firmware_version, forKey: .firmware_version)
        try container.encodeIfPresent(bindTime, forKey: .bindTime)
    }
}
