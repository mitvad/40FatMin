//
//  WorkoutProgramPart.swift
//  40FatMin
//
//  Created by Vadym on 212//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

class WorkoutProgramPart{
    
// MARK: - Initializers
    
    init(pulseZoneType: PulseZoneType, duration: TimeInterval) {
        self.pulseZoneType = pulseZoneType
        self.duration = duration
    }
    
// MARK: - Public Properties
    
    var duration: TimeInterval
    var pulseZoneType: PulseZoneType

}
