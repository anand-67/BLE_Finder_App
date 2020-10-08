


import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var bleTableView: UITableView!
    
    var centralManager: CBCentralManager!
    
    var foundPheripherals =  [CBPeripheral]()
    
    var myCharacteristic:CBCharacteristic?
    
    @IBOutlet weak var scanDeviceBtn: UIButton!
    
    var deviceDict = [String:CBPeripheral]()
    
    var isCentralOn:Bool = false
    
    var seriveIds = [CBUUID(string:"FFE0")]
    
    var bleDevices = [BLEDevice]()
    
    var timer:Timer?
    
    var calledCount = 0
    
    var seletedPheripheral:CBPeripheral?
    
    var isMyPeripheralConected:Bool = false
    
    var newTimer = Timer()

    
    override func viewDidLoad() {
        print("viewDidLoad")
        self.bleTableView.isHidden = true
        self.bleTableView.tableFooterView = UIView()
        super.viewDidLoad()
        self.title = "East - West - College - Project"
        centralManager = CBCentralManager(delegate: self, queue: nil)
        newTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(newfire), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
    }
    
    @objc func newfire(){
           print("asdadsdasd")
       }
    
    @objc func fire(){
        print("FIRE!!!")
        scan()
    }
    
    @IBAction func scanDeviceAction(_ sender: UIButton) {
       scan()
       timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    func scan() {
        if self.isCentralOn {
            centralManager.scanForPeripherals(withServices: seriveIds, options: nil)
        }
    }
}

// MARK:-- CustomCellDelegate

extension ViewController: CustomCellDelegate {
    func toggleLED(sender: UISwitch) {
        if sender.isOn {
            self.writeValue(onOff: "1")
        } else {
            self.writeValue(onOff: "0")
        }
    }
    
    func connectAction(index: Int?, pheripheral: CBPeripheral?) {
        if let peri = self.seletedPheripheral, let periNew = pheripheral {
            if peri.identifier != periNew.identifier {
                if peri.state == .connected {
                    self.writeValue(onOff: "0")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.centralManager.cancelPeripheralConnection(peri)
                        self.centralManager.connect(periNew, options: nil)
                    }
                }
            } else {
                self.writeValue(onOff: "0")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 self.centralManager.cancelPeripheralConnection(peri)
                }
            }
        } else if let peri = pheripheral {
            self.centralManager.connect(peri, options: nil)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bleDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.customCellDelegate = self
        if !self.bleDevices.isEmpty {
            cell.selectedPheripheral = self.bleDevices[indexPath.row].pheriphereal
            if let selectedPeri = self.seletedPheripheral {
                if selectedPeri.identifier ==  cell.selectedPheripheral?.identifier {
                   cell.toggleLed.isHidden = false
                } else {
                   cell.toggleLed.isHidden = true
                }
            } else {
                cell.toggleLed.isHidden = true
                cell.toggleLed.isOn = false
            }
            cell.configureCell(bleDevice: self.bleDevices[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}

// MARK:-- CBCentralManagerDelegate

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff: print("poweredOff")
              isCentralOn = false
        case .poweredOn: print("poweredOn")
              isCentralOn = true
        case .resetting: print("resetting")
        case .unauthorized: print("unauthorized")
        case .unknown : print("unknown")
        case .unsupported: print("unsupported")
        default: break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       // print("peripheral= \(peripheral)")
        calledCount += 1
        //print("calledCount == \(calledCount)")
        if let name = peripheral.name {
            if name == BluetoothDeviceNames.MLTBT05.rawValue {
                let newBleDevices = BLEDevice(pheripherealDev: peripheral, rssiValue: RSSI)
                if self.bleDevices.count < 2 {
                    if let ele = self.bleDevices.first{
                        if let per = ele.pheriphereal {
                            if per.identifier != newBleDevices.pheriphereal?.identifier{
                               self.bleDevices.append(newBleDevices)
                            }
                        }
                    }else {
                     self.bleDevices.append(newBleDevices)
                    }
                } else {
                    if let peri = newBleDevices.pheriphereal {
                        for device in self.bleDevices {
                            if let periNew = device.pheriphereal {
                                if peri.identifier == periNew.identifier{
                                    device.rssiValu = RSSI
                                }
                            }
                        }
                    }
                }
                self.bleTableView.isHidden = false
                if self.bleDevices.count == 2 && self.calledCount == 2{
                    var bleDevice1:BLEDevice?
                    var bleDevice2:BLEDevice?
                    self.calledCount = 0
                    for (index,ele) in self.bleDevices.enumerated() {
                        if index == 0 {
                           bleDevice1 = ele
                        } else {
                           bleDevice2 = ele
                        }
                    }
                    if let dev1 = bleDevice1, let dev2 = bleDevice2 {
                        if let rssi1 = dev1.rssiValu, let rssi2 = dev2.rssiValu {
                            let result = rssi1.compare(rssi2)
                            print(result.rawValue)
                            if result == .orderedAscending {
                                self.bleDevices = []
                                self.bleDevices.append(dev2)
                                self.bleDevices.append(dev1)
                                print("self.bleDevices[0].pheriphereal ==== \(self.bleDevices[0].pheriphereal)")
                                print("self.bleDevices[1].pheriphereal ==== \(self.bleDevices[1].pheriphereal)")
                            } else {
                                self.bleDevices = []
                                self.bleDevices.append(dev1)
                                self.bleDevices.append(dev2)
                                print("self.bleDevices[0].pheriphereal ==== \(self.bleDevices[0].pheriphereal)")
                                print("self.bleDevices[1].pheriphereal ==== \(self.bleDevices[1].pheriphereal)")
                            }
                        }
                    }
                }
                
               // self.bleTableView.reloadData()
                //self.bleTableView.reloadRows(at: [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)], with: .top)
                self.bleTableView.reloadWithAnimation()
            }
        }
    }
        
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
       // print("peripheral= \(peripheral)")
        peripheral.delegate = self
        self.isMyPeripheralConected = true
        self.seletedPheripheral = peripheral
        self.seletedPheripheral?.discoverServices(nil)
        self.timer?.invalidate()
       // self.bleTableView.reloadData()
        self.bleTableView.reloadWithAnimation()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        self.isMyPeripheralConected = false
        self.myCharacteristic = nil
        self.seletedPheripheral = nil
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
        //self.bleTableView.reloadData()
        self.bleTableView.reloadWithAnimation()
    }
}

extension ViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let servicePeripheral = peripheral.services as [CBService]? { //get the services of the perifereal
            for service in servicePeripheral {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]? {
            for cc in characterArray {
                if(cc.uuid.uuidString == "FFE1") { //properties: read, write
                    //if you have another BLE module, you should print or look for the characteristic you need.
                    myCharacteristic = cc //saved it to send data in another function.
                }
            }
        }
    }
    
    func writeValue(onOff : String) {
        
        if isMyPeripheralConected { //check if myPeripheral is connected to send data
            
            let dataToSend: Data = onOff.data(using: String.Encoding.utf8)!
            if let peri = self.seletedPheripheral {
                if let chracters = self.myCharacteristic {
                  peri.writeValue(dataToSend, for: chracters, type: CBCharacteristicWriteType.withoutResponse)
                }
            }//Writing the data to the peripheral
        } else {
            print("Not connected")
        }
    }
}

