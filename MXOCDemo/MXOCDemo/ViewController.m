//
//  ViewController.m
//  MXOCDemo
//
//  Created by huafeng on 2024/4/3.
//

#import "ViewController.h"
#import "MXFogProvision/MXFogProvision-Swift.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource, MXFogProvisionDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, assign) NSInteger requestNum;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn.frame = CGRectMake((self.view.frame.size.width-220)/2.0, 20, 100, 40);
    [btn setTitle:@"重新扫描" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(scanDevices) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn2.frame = CGRectMake(CGRectGetMaxX(btn.frame) + 20, 20, 100, 40);
    [btn2 setTitle:@"一键配网" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(startWifiProvsion) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn2];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = headerView;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanDevices];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// 3.发现设备
- (void)scanDevices {
    NSLog(@"scanDevices");
    [MXFogBleScan.shared startScanWithTimeout:0 callback:^(NSArray<NSDictionary<NSString *,id> *> * _Nonnull devices, BOOL isStop) {
        self.list = devices;
        [self.tableView reloadData];
    }];
}

// 一键配网
- (void)startWifiProvsion {
    NSMutableDictionary *custom = [[NSMutableDictionary alloc] init];
    custom[@"htturl"] = @"app.api.fogcloud.io";
    custom[@"mqtturl"] = @"app.mqtt.fogcloud.io";
    [MXEasyLinkProvision.shared startProvisionWithPk:nil ssid:@"mxchip-guest" password:@"12345678" custom:custom timeout:30 delegate:self];
}

#pragma mark - UITableViewDelegate UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];;
    }
    if (self.list.count > indexPath.row) {
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
        cell.textLabel.text = [info objectForKey:@"name"];
        cell.detailTextLabel.text = [info objectForKey:@"mac"];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.list.count > indexPath.row) {
        //开始配网
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
        [MXFogBleScan.shared stopScan];
        NSString *pk = info[@"productKey"];
        NSString *dn = info[@"deviceName"];
        CBPeripheral *peripheral = info[@"peripheral"];
        
        [MXFogBleProvision.shared provisionDeviceWithPeripheral:peripheral productKey:pk deviceName:dn timeout:30 delegate:self];
    }
}

#pragma  mark -----------------------

- (void)mxFogProvisionInputWifiInfoWithProductKey:(NSString *)productKey deviceName:(NSString *)deviceName handler:(void (^)(NSString * _Nonnull, NSString * _Nullable, NSDictionary<NSString *,id> * _Nullable))handler {
    NSMutableDictionary *custom = [[NSMutableDictionary alloc] init];
    custom[@"htturl"] = @"app.api.fogcloud.io";
    custom[@"mqtturl"] = @"app.mqtt.fogcloud.io";
    handler(@"mxchip-guest", @"12345678", custom);
}

- (void)mxFogProvisionFinishWithProductKey:(NSString *)productKey deviceName:(NSString *)deviceName error:(NSError *)error {
    [MXFogBleProvision.shared cleanProvisionCache];
    if (error != nil) {
        NSLog(@"失败原因：%@", error);
    } else {
        //配网成功
    }
}

- (void)mxFogProvisionRequestRandomWithProductKey:(NSString *)productKey deviceName:(NSString *)deviceName handler:(void (^)(NSString * _Nullable))handler {
    NSString *randomStr = [MXFogBleProvision.shared createRandom];
    handler(randomStr);
}

- (void)mxFogProvisionRequestBleKeyWithProductKey:(NSString *)productKey deviceName:(NSString *)deviceName random:(NSString *)random cipher:(NSString *)cipher handler:(void (^)(NSString * _Nullable))handler {
    //模拟实现本地存储了设备信息，通过deviceSecret生成bleKey
    //通过productKey & deviceName，找到设备的ds
    NSString *ds = @"ac99f9066b51b9ed3885db9dabd7e380";
    NSString *bleKey = [MXFogBleProvision.shared createBleKeyWithSecret:ds];
    if (bleKey) {
        handler(bleKey);
    }
}

- (void)mxFogProvisionRequestConnectStatusWithProductKey:(NSString *)productKey deviceName:(NSString *)deviceName random:(NSString *)random handler:(void (^)(BOOL))handler {
    //模拟轮询3次之后，设备连接成功
    self.requestNum += 1;
    if (self.requestNum > 3) {
        handler(true);
    } else {
        handler(false);
    }
}

@end
