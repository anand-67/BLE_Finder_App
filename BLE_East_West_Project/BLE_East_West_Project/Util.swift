

import Foundation
import UIKit
import CoreBluetooth

class BLEDevice {
    var pheriphereal:CBPeripheral?
    var rssiValu:NSNumber?
    
    init(pheripherealDev:CBPeripheral, rssiValue:NSNumber) {
        self.pheriphereal = pheripherealDev
        self.rssiValu = rssiValue
    }
}


extension UITableView {
    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.7, delay: 0.08 * Double(delayCounter),usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveLinear, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
    func reloadData(with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
           let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
           let scanner = Scanner(string: hexString)
           
           if (hexString.hasPrefix("#")) {
               scanner.scanLocation = 1
           }
           
           var color: UInt32 = 0
           scanner.scanHexInt32(&color)
           
           let mask = 0x000000FF
           let r = Int(color >> 16) & mask
           let g = Int(color >> 8) & mask
           let b = Int(color) & mask
           
           let red   = CGFloat(r) / 255.0
           let green = CGFloat(g) / 255.0
           let blue  = CGFloat(b) / 255.0
           
           self.init(red:red, green:green, blue:blue, alpha:alpha)
       }
    
    static func hexStringToUIColor(hex:String, alpha: Float = 1.0) -> UIColor {
           var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
           
           if (cString.hasPrefix("#")) {
               cString.remove(at: cString.startIndex)
           }
           
           if ((cString.count) != 6) {
               return UIColor.gray
           }
           
           var rgbValue:UInt32 = 0
           Scanner(string: cString).scanHexInt32(&rgbValue)
           
           return UIColor(
               red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
               green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
               blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
               alpha: CGFloat(alpha)
           )
       }
    
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),green: .random(in: 0...1),blue: .random(in: 0...1),alpha: 1.0)
    }
}

enum BluetoothDeviceNames:String {
    case MLTBT05 = "MLT-BT05"
}

enum BluetoothDeviceIds:String {
    case first = "37A78863-4B95-7643-1C1E-14226393ADEC"
    case second = "F3F2ACDF-6306-A066-2325-A49871D921C1"
}
