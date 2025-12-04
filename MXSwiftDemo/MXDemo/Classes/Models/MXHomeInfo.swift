
import Foundation

public class MXHomeInfo: NSObject, Codable {
    
    public var homeId: Int = 0
    public var name: String?
    
    public var devices: [MXDeviceInfo] = [MXDeviceInfo]()
    
    private enum CodingKeys: String, CodingKey {
        case homeId
        case name
        case devices
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.homeId = (try? container.decode(Int.self, forKey: .homeId)) ?? 0
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.devices = (try? container.decode([MXDeviceInfo].self, forKey: .devices)) ?? [MXDeviceInfo]()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(homeId, forKey: .homeId)
        try container.encodeIfPresent(name, forKey: .name)
        try? container.encode(devices, forKey: .devices)
    }
}
