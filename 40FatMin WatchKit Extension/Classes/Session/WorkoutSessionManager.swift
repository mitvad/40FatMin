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
            return currentWorkoutSession?.state ?? .notStarted
        }
    }
    
// MARK: - Public Methods
    
    func startSession(){
        guard self.currentWorkoutSession == nil else{
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
            
            self.currentWorkoutSession = session
        }
        catch let error as NSError {
            // Perform proper error handling here...
            fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
        }
    }
    
    func stopSession(){
        if let session = self.currentWorkoutSession{
            healthStore.end(session)
        }
    }
    
    func pauseSession(){
        if let session = self.currentWorkoutSession{
            healthStore.pause(session)
        }
    }
    
    func resumeSession(){
        if let session = self.currentWorkoutSession{
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
    
    fileprivate var currentWorkoutSession: HKWorkoutSession?
    fileprivate var workoutSessions = [(start: Date, end: Date)]()
    
    fileprivate let heartRateUnit = HKUnit(from: "count/min")
    fileprivate var heartRateQuery: HKAnchoredObjectQuery?
    
// MARK: - Private Computed Properties
    
    fileprivate var dateForTimer: Date{
        get{
            var duration = 0.0
            
            for (start, end) in workoutSessions{
                duration += end.timeIntervalSince(start)
            }
            
            return Date(timeInterval: -duration, since: Date())
        }
    }
    
// MARK: - Private Methods
    
    fileprivate func sessionDidStart(_ sessionStartDate: Date){
        createHeartRateStreamingQuery(sessionStartDate)
    }
    
    fileprivate func sessionDidPaused(){
        if let heartRateQuery = heartRateQuery{
            healthStore.stop(heartRateQuery)
            self.heartRateQuery = nil
        }
        
        if let session = self.currentWorkoutSession{
            guard let start = session.startDate else {return}
            
            workoutSessions.append((start: start, end: Date()))
        }
    }
    
    fileprivate func sessionDidEnd(){
        if let heartRateQuery = heartRateQuery{
            healthStore.stop(heartRateQuery)
            self.heartRateQuery = nil
        }
        
        currentWorkoutSession = nil
    }
    
    fileprivate func createHeartRateStreamingQuery(_ sessionStartDate: Date){
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: sessionStartDate, end: nil, options: .strictEndDate )
        
        heartRateQuery = HKAnchoredObjectQuery(type: quantityType,
                                               predicate: datePredicate,
                                               anchor: nil,
                                               limit: HKObjectQueryNoLimit)
        { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery!.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        
        healthStore.execute(heartRateQuery!)
    }
    
    fileprivate func updateHeartRate(_ samples: [HKSample]?){
        guard let heartRateSamples = samples as? [HKQuantitySample] else {
            return
        }
        
        guard let sample = heartRateSamples.first else{
            return
        }
        
        let value = sample.quantity.doubleValue(for: self.heartRateUnit)
        
        print("Heart rate: \(value)")
        
        DispatchQueue.main.async {
            self.delegate?.workoutSessionManager?(self, heartRateDidChangeTo: value)
        }
    }
    
}

// MARK: - Extension HKWorkoutSessionDelegate

extension WorkoutSessionManager: HKWorkoutSessionDelegate{
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session did fail with error: \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        print("Workout state changed from: \(fromState.rawValue) to: \(toState.rawValue)")
        
        var dateForTimer = date
        
        switch toState {
        case .running:
            sessionDidStart(date)
            dateForTimer = self.dateForTimer
        case .ended:
            sessionDidEnd()
        case .paused:
            sessionDidPaused()
        case .notStarted:
            break
        }
        
        delegate?.workoutSessionManager?(self, sessionDidChangeTo: toState, from: fromState, dateForTimer: dateForTimer)
    }
}
