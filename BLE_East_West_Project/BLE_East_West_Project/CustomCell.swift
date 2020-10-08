
import UIKit
import CoreBluetooth

protocol CustomCellDelegate:AnyObject {
    func connectAction(index:Int?, pheripheral:CBPeripheral?)
    func toggleLED(sender:UISwitch)
}

class CustomCell: UITableViewCell {

    @IBOutlet weak var rssiDisplayLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var toggleLed: UISwitch!
    
    weak var customCellDelegate:CustomCellDelegate?
    
    var index:Int?
    
    var selectedPheripheral:CBPeripheral?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    func setUp() {
        self.connectBtn.backgroundColor = UIColor.init(hexString: "#5f2f00", alpha: 1.0)
        
        rssiDisplayLabel.layer.cornerRadius = rssiDisplayLabel.layer.frame.height/2
        rssiDisplayLabel.layer.masksToBounds = true

        connectBtn.layer.cornerRadius = 15
        connectBtn.layer.masksToBounds = true
        
        self.toggleLed.isOn = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func connectAction(_ sender: UIButton) {
        customCellDelegate?.connectAction(index: self.index, pheripheral: selectedPheripheral)
    }
    
    func configureCell(bleDevice:BLEDevice){
        if let peripheral = bleDevice.pheriphereal, let name = peripheral.name {
            nameLabel.text = name
            if peripheral.state == .connected {
                self.connectBtn.backgroundColor = UIColor.init(hexString: "#008100", alpha: 1.0)
                self.connectBtn.setTitle("Disconnect", for: .normal)
                
            } else {
                 self.connectBtn.backgroundColor = UIColor.init(hexString: "#5f2f00", alpha: 1.0)
                self.connectBtn.setTitle("Connect", for: .normal)
            }
        }
        if let rssiValue = bleDevice.rssiValu {
            rssiDisplayLabel.text = "\(rssiValue)"
        }
    }
    
    @IBAction func toggleAction(_ sender: UISwitch) {
        customCellDelegate?.toggleLED(sender: sender)
    }
}
