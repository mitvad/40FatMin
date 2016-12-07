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
    
    init(pulseZoneType: PulseZoneType, duration: TimeInterval, startTime: TimeInterval) {
        self.pulseZoneType = pulseZoneType
        self.duration = duration
        self.startTime = startTime
        self.endTime = startTime + duration
    }
    
// MARK: - Public Properties
    
    var pulseZoneType: PulseZoneType
    var duration: TimeInterval
    var startTime: TimeInterval
    var endTime: TimeInterval

// MARK: - Public Methods
    
    func contains(time: TimeInterval) -> Bool{
        return (startTime <= time && time < endTime) ? true : false
    }
}
