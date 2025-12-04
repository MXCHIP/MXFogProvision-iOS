
import Foundation

class MXHomeManager: NSObject {
    public static var shard = MXHomeManager()
    public var homeList = Array<MXHomeInfo>()
    
    public var currentHome : MXHomeInfo? = nil {
        didSet {
            if self.currentHome == nil {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
        }
    }
    
    override init() {
        super.init()
        self.loadMXHomeData()
        self.refreshCurrentHome()
    }
    
    public func refreshCurrentHome() {
        if self.homeList.count > 0 {
            self.currentHome = self.homeList.first
        } else {
            self.createHome(name: "My Home")
        }
    }
    
}

extension MXHomeManager {
    
    func createHomeId() -> Int {
        var home_id = 1
        if let last = self.homeList.max(by: {$0.homeId < $1.homeId}), last.homeId >= home_id {
            home_id = last.homeId + 1
        }
        return home_id
    }
    
    func createHome(name:String) {
        let newHome = MXHomeInfo()
        newHome.homeId = self.createHomeId()
        newHome.name = name
        self.homeList.append(newHome)
        
        self.currentHome = newHome
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
        self.updateHomeList()
    }
}

extension MXHomeManager {
    
    func loadMXHomeData() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXHomeData.json")
        if let data = try? Data(contentsOf: url) {
            if let params = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [[String : Any]],
                let list = MXHomeInfo.mx_Decode(params) {
                self.homeList = list
            }
        }
    }
    
    public func updateHomeList() {
        var home_list = [[String: Any]]()
        self.homeList.forEach { (home:MXHomeInfo) in
            if let params = MXHomeInfo.mx_keyValue(home) {
                home_list.append(params)
            }
        }
        self.updateMXHomeData(params: home_list)
    }
    
    
    public func updateMXHomeData(params: [[String : Any]]) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXHomeData.json")
        if let data = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed) {
            try? data.write(to: url)
        }
    }
}

