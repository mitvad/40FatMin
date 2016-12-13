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
    
    var multicastDelegate = MulticastDelegate<WorkoutSessionManagerDelegate>()
    
    weak var workout: Workout!
    
    weak var workoutProgram: WorkoutProgram?
    weak var currentWorkoutProgramPart: WorkoutProgramPart?{
        didSet{
            guard let pulseZones = ((WKExtension.shared().delegate as? ExtensionDelegate)?.pulseZones) else {return}
            
            guard let currentWorkoutProgramPart = currentWorkoutProgramPart else {
                if oldValue != nil{
                    multicastDelegate.invoke{delegate in delegate.workoutSessionManager?(self, programDidFinish: true)}
                    
                    currentPulseZone = pulseZones.pulseZone(forType: PulseZoneType.z0)
                }
                
                return
            }
            
            currentPulseZone = pulseZones.pulseZone(forType: currentWorkoutProgramPart.pulseZoneType)
        }
    }
    
    weak var currentPulseZone: PulseZone!{
        didSet{
            if currentPulseZone != oldValue{
                multicastDelegate.invoke{delegate in delegate.workoutSessionManager?(self, pulseZoneDidChangeTo: currentPulseZone, from: oldValue)}
            }
        }
    }
    
    fileprivate var sessionStartDateCache: Date?
    var sessionStartDate: Date{
        get{
            if let sessionStartDateCache = sessionStartDateCache{
                return sessionStartDateCache
            }
            
            var duration = 0.0
            
            for (start, end) in workoutSessions{
                duration += end.timeIntervalSince(start)
            }
            
            self.sessionStartDateCache = Date(timeInterval: -duration, since: Date())
            
            return self.sessionStartDateCache!
        }
    }
    
    private(set) var distanceTotal = 0.0
    
// MARK: - Public Computed Properties
    
    var sessionState: HKWorkoutSessionState{
        get{
            return currentWorkoutSession?.state ?? .notStarted
        }
    }
    
// MARK: - Public Methods
    
    func reinit(workout: Workout, pulseZone: PulseZone){
        initDefaults()
        
        self.workout = workout
        self.currentPulseZone = pulseZone
    }
    
    func reinit(workout: Workout, workoutProgram: WorkoutProgram){
        let pulseZone = ((WKExtension.shared().delegate as? ExtensionDelegate)?.pulseZones)!.pulseZone(forType: workoutProgram.firstPart.pulseZoneType)
        
        reinit(workout: workout, pulseZone: pulseZone)
        
        self.workoutProgram = workoutProgram
        
        self.currentWorkoutProgramPart = workoutProgram.firstPart
    }
    
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
        
        WKInterfaceDevice.current().play(.success)
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
    
    func workoutStartDate() -> Date{
        if !workoutSessions.isEmpty{
            return workoutSessions.first!.start
        }
        
        return Date()
    }
    
    func workoutEndDate() -> Date{
        if !workoutSessions.isEmpty{
            return workoutSessions.last!.end
        }
        
        return Date()
    }
    
// MARK: - Private Properties
    
    fileprivate var currentWorkoutSession: HKWorkoutSession?
    fileprivate var workoutSessions = [(start: Date, end: Date)]()
    
    fileprivate let heartRateUnit = HKUnit(from: "count/min")
    fileprivate var heartRateQuery: HKAnchoredObjectQuery?
    
    fileprivate var distanceQuery: HKAnchoredObjectQuery?
    fileprivate var distanceUnit = HKUnit(from: "m")
    
// MARK: - Private Computed Properties
    
    fileprivate var healthStore: HKHealthStore{
        get{
            return ((WKExtension.shared().delegate as? ExtensionDelegate)?.healthStore)!
        }
    }
    
    fileprivate var pulseZones: PulseZones{
        get{
            return ((WKExtension.shared().delegate as? ExtensionDelegate)?.pulseZones)!
        }
    }
    
    fileprivate var isProgramPartShouldChange: Bool{
        get{
            guard let currentWorkoutProgramPart = self.currentWorkoutProgramPart else {return false}
            
            let sessionDuration = Date().timeIntervalSince(self.sessionStartDate)
            
            return !currentWorkoutProgramPart.contains(time: sessionDuration)
        }
    }
    
// MARK: - Private Methods
    
    fileprivate func initDefaults(){
        multicastDelegate.removeAllDelegates()
        
        self.workoutProgram = nil
        self.currentWorkoutProgramPart = nil
        
        currentWorkoutSession = nil
        workoutSessions = [(start: Date, end: Date)]()
        sessionStartDateCache = nil
        
        heartRateQuery = nil
        
        distanceQuery = nil
        distanceTotal = 0.0
    }
    
    fileprivate func sessionDidStart(_ sessionStartDate: Date){
        createHeartRateStreamingQuery(sessionStartDate)
        createDistanceStreamingQuery(sessionStartDate)
    }
    
    fileprivate func sessionDidPaused(){
        stopQueries()
        
        if let session = self.currentWorkoutSession{
            guard let start = session.startDate else {return}
            
            workoutSessions.append((start: start, end: Date()))
            
            sessionStartDateCache = nil
        }
    }
    
    fileprivate func sessionDidEnd(){
        stopQueries()
        
        currentWorkoutSession = nil
    }
    
    fileprivate func stopQueries(){
        if let heartRateQuery = heartRateQuery{
            healthStore.stop(heartRateQuery)
            self.heartRateQuery = nil
        }
        
        if let distanceQuery = distanceQuery{
            healthStore.stop(distanceQuery)
            self.distanceQuery = nil
        }
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
    
    fileprivate func createDistanceStreamingQuery(_ sessionStartDate: Date){
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else {
            return
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: sessionStartDate, end: nil, options: .strictEndDate )
        
        distanceQuery = HKAnchoredObjectQuery(type: quantityType,
                                               predicate: datePredicate,
                                               anchor: nil,
                                               limit: HKObjectQueryNoLimit)
        { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateDistance(sampleObjects)
        }
        
        distanceQuery!.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateDistance(samples)
        }
        
        healthStore.execute(distanceQuery!)
    }
    
    fileprivate func updateDistance(_ samples: [HKSample]?){
        guard let distanceSamples = samples as? [HKQuantitySample] else {
            return
        }
        
        guard let sample = distanceSamples.first else{
            return
        }
        
        distanceTotal += sample.quantity.doubleValue(for: self.distanceUnit)
        
        print("updateDistance \(distanceTotal)")
        
        DispatchQueue.main.async {
            self.multicastDelegate.invoke{delegate in delegate.workoutSessionManager?(self, distanceDidChangeTo: self.distanceTotal)}
        }
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
        
        if isProgramPartShouldChange{
            changeCurrentProgramPart()
            
            WKInterfaceDevice.current().play(.success)
        }
        else{
            var heartRateIsOut = false
            var isAbove = false
            var actualPulseZone = self.currentPulseZone
            
            if value < self.currentPulseZone.range.lowerBound{
                WKInterfaceDevice.current().play(.stop)
                
                heartRateIsOut = true
                isAbove = false
            }
            else if value > currentPulseZone.range.upperBound{
                WKInterfaceDevice.current().play(.start)
                
                heartRateIsOut = true
                isAbove = true
            }
            
            if heartRateIsOut{
                actualPulseZone = ((WKExtension.shared().delegate as? ExtensionDelegate)?.pulseZones)!.pulseZone(forPulse: value)
            }
            
            DispatchQueue.main.async {
                self.multicastDelegate.invoke{delegate in delegate.workoutSessionManager?(self, heartRateIsOutOfPulseZoneRange: heartRateIsOut, isAbovePulseZoneRange: isAbove, actualPulseZone: actualPulseZone)}
            }
        }
        
        DispatchQueue.main.async {
            self.multicastDelegate.invoke{delegate in delegate.workoutSessionManager?(self, heartRateDidChangeTo: value)}
        }
    }
    
    fileprivate func changeCurrentProgramPart(){
        guard let workoutProgram = self.workoutProgram else {return}
        
        let sessionDuration = Date().timeIntervalSince(self.sessionStartDate)
        
        self.currentWorkoutProgramPart = workoutProgram.part(forTime: sessionDuration)
        
        DispatchQueue.main.async {
            self.multicastDelegate.invoke{delegate in delegate.workoutSessionManager?(self, programPartDidChangeTo: self.currentWorkoutProgramPart)}
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
        
        var sessionStartDate = date
        
        switch toState {
        case .running:
            sessionDidStart(date)
            sessionStartDate = self.sessionStartDate
        case .ended:
            sessionDidEnd()
        case .paused:
            sessionDidPaused()
        case .notStarted:
            break
        }
        
        multicastDelegate.invoke{delegate in delegate.workoutSessionManager?(self, sessionDidChangeTo: toState, from: fromState, date: sessionStartDate)}
    }
}
