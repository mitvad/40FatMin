//
//  PulseZoneType.swift
//  40FatMin
//
//  Created by Vadym on 412//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import UIKit

enum PulseZoneType: String{
    case z0
    case z1
    case z2
    case z3
    case z4

// MARK: - Public Computed Properties
    
    var title: String{
        get{
            switch self {
            case .z0:
                return NSLocalizedString("Zone 0", comment: "Any pulse zone")
            case .z1:
                return NSLocalizedString("Zone 1", comment: "Pulse Zone 1")
            case .z2:
                return NSLocalizedString("Zone 2", comment: "Pulse Zone 2")
            case .z3:
                return NSLocalizedString("Zone 3", comment: "Pulse Zone 3")
            case .z4:
                return NSLocalizedString("Zone 4", comment: "Pulse Zone 4")
            }
        }
    }
    
    var shortTitle: String{
        get{
            switch self {
            case .z0:
                return NSLocalizedString("Z0", comment: "Any pulse zone short name (2 characters)")
            case .z1:
                return NSLocalizedString("Z1", comment: "Pulse Zone 1 short name (2 characters)")
            case .z2:
                return NSLocalizedString("Z2", comment: "Pulse Zone 2 short name (2 characters)")
            case .z3:
                return NSLocalizedString("Z3", comment: "Pulse Zone 3 short name (2 characters)")
            case .z4:
                return NSLocalizedString("Z4", comment: "Pulse Zone 4 short name (2 characters)")
            }
        }
    }
    
    var backgroundColor: UIColor{
        get{
            switch self {
            case .z0:
                return UIColor.init(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
            case .z1:
                return UIColor.init(red: 0.649, green: 1.000, blue: 0.000, alpha: 1.000)
            case .z2:
                return UIColor.init(red: 1.000, green: 0.587, blue: 0.000, alpha: 1.000)
            case .z3:
                return UIColor.init(red: 0.645, green: 0.000, blue: 0.645, alpha: 1.000)
            case .z4:
                return UIColor.init(red: 0.980, green: 0.069, blue: 0.311, alpha: 1.000)
            }
        }
    }
    
    var textColor: UIColor{
        get{
            switch self {
            case .z0:
                return UIColor.init(red: 1.000 , green: 0.587, blue: 0.000, alpha: 1.000)
            case .z1, .z2, .z3, .z4:
                return UIColor.init(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
            }
        }
    }
}
