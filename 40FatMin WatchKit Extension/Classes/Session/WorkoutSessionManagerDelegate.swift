//
//  WorkoutSessionManagerDelegate.swift
//  40FatMin
//
//  Created by Vadym on 212//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import HealthKit

@objc protocol WorkoutSessionManagerDelegate{
    
    @objc optional func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, sessionDidChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date)
    
    @objc optional func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, pulseZoneDidChangeTo toPulseZone: PulseZone, from fromPulseZone: PulseZone)
    
    @objc optional func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, programPartDidChangeTo toProgramPart: WorkoutProgramPart?)
    
    @objc optional func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, heartRateDidChangeTo toHeartRate: Double)
    
    @objc optional func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, distanceDidChangeTo toDistance: Double)
    
    @objc optional func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, heartRateIsOutOfPulseZoneRange isOut: Bool, isAbovePulseZoneRange isAbove: Bool, actualPulseZone pulseZone: PulseZone?)
    
    @objc optional func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, programDidFinish success: Bool)
}
