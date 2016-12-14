//
//  UserDefaults+AppKeys.swift
//  40FatMin
//
//  Created by Vadym on 512//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

extension UserDefaults{
    
    static var KeyProgramSelectionScreen: String{
        get{
            return "KeyProgramSelectionScreen"
        }
    }
    
    static var KeyZoneSelectionScreen: String{
        get{
            return "KeyZoneSelectionScreen"
        }
    }
    
    static var SessionMetricsDisplayState: String{
        get{
            return "SessionMetricsDisplayState"
        }
    }
}
