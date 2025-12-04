
import Foundation

class MXDeviceManager: NSObject {
    public static var shard = MXDeviceManager()
    
    override init() {
        super.init()
    }
    
    func loadDevices() -> [MXDeviceInfo] {
        return MXHomeManager.shard.currentHome?.devices ?? [MXDeviceInfo]()
    }
    
    func update(device:MXDeviceInfo?, isSave:Bool = true) {
        guard let device = device else {
            return
        }
        if let index = MXHomeManager.shard.currentHome?.devices.firstIndex(where: {$0.isSameFrom(device)}) {
            MXHomeManager.shard.currentHome?.devices[index] = device
        }

        if isSave {
            MXHomeManager.shard.updateHomeList()
        }
    }
    
    
    func add(device:MXDeviceInfo?, isSave:Bool = true) {
        guard let device = device else {
            return
        }
        MXHomeManager.shard.currentHome?.devices.removeAll(where: {$0.isSameFrom(device)})
        MXHomeManager.shard.currentHome?.devices.append(device)

        if isSave {
            MXHomeManager.shard.updateHomeList()
        }
    }
    
    func delete(device:MXDeviceInfo?, isSave:Bool = true, index: Int = 3, callback:(() -> Void)? = nil) {
        guard let device = device else {
            return
        }
        MXHomeManager.shard.currentHome?.devices.removeAll(where: {$0.isSameFrom(device)})
        if isSave {
            MXHomeManager.shard.updateHomeList()
        }
        callback?()
    }
}
