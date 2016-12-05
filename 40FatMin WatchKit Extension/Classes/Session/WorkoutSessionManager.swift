//
//  WorkoutSessionManager.swift
//  40FatMin
//
//  Created by Vadym on 212//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit

class WorkoutSessionManager: NSObject{
    
// MARK: - Initializers
    
    init(workout: Workout, pulseZone: PulseZone){
        self.healthStore = ((WKExtension.shared().delegate as? ExtensionDelegate)?.healthStore)!
        self.pulseZones = ((WKExtension.shared().delegate as? ExtensionDelegate)?.pulseZones)!
        self.workout = workout
        self.currentPulseZone = pulseZone
        
        super.init()
    }
    
    convenience init(workout: Workout, workoutProgram: WorkoutProgram){
        let pulseZone = ((WKExtension.shared().delegate as? ExtensionDelegate)?.pulseZones)!.pulseZone(forType: workoutProgram.firstPart.pulseZoneType)
        
        self.init(workout: workout, pulseZone: pulseZone)
        
        self.workoutProgram = workoutProgram
        
        self.currentWorkoutProgramPart = workoutProgram.firstPart
    }
    
// MARK: - Public Properties
    
    weak var delegate: WorkoutSessionManagerDelegate?
    
    var workoutProgram: WorkoutProgram?
    var currentWorkoutProgramPart: WorkoutProgramPart?
    
    var currentPulseZone: PulseZone!{
        didSet{
            delegate?.workoutSessionManager?(self, pulseZoneDidChangeTo: currentPulseZone, from: oldValue)
        }
    }
    
// MARK: - Public Computed Properties
    
    var sessionState: HKWorkoutSessionState{
        get{
            return workoutSession?.state ?? .notStarted
        }
    }
    
// MARK: - Public Methods
    
    func startSession(){
        guard self.workoutSession == nil else{
            print("Warning: workout session is already started")
            return
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .indoor
        
        do {
            let session = try HKWorkoutSession(configuration: configuration)
            
            session.delegate = self
            healthStore.start(session)
            
            self.workoutSession = session
        }
        catch let error as NSError {
            // Perform proper error handling here...
            fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
        }
    }
    
    func stopSession(){
        if let session = self.workoutSession{
            healthStore.end(session)
        }
    }
    
    func pauseSession(){
        if let session = self.workoutSession{
            healthStore.pause(session)
        }
    }
    
    func resumeSession(){
        if let session = self.workoutSession{
            healthStore.resumeWorkoutSession(session)
        }
    }
    
    func setPulseZone(zone: PulseZone){
        currentPulseZone = zone
    }
    
// MARK: - Private Properties
    
    fileprivate var workout: Workout
    
    fileprivate var healthStore: HKHealthStore
    fileprivate var pulseZones: PulseZones
    
    fileprivate var workoutSession: HKWorkoutSession?
    
}

// MARK: - Extension HKWorkoutSessionDelegate

extension WorkoutSessionManager: HKWorkoutSessionDelegate{
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session did fail with error: \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print(event)
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        print("Workout state changed from: \(fromState.rawValue) to: \(toState.rawValue)")
        
        delegate?.workoutSessionManager?(self, sessionDidChangeTo: toState, from: fromState, date: date)
    }
}
