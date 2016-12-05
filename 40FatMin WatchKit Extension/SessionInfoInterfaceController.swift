//
//  SessionInterfaceController.swift
//  40FatMin
//
//  Created by Vadym on 2811//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit

class SessionInterfaceController: WKInterfaceController{
    
    @IBOutlet var sessionTimer: WKInterfaceTimer!
    @IBOutlet var heartRate: WKInterfaceLabel!
    
    var healthStore: HKHealthStore?
    
    var session: HKWorkoutSession?
    var sessionState: HKWorkoutSessionState = .notStarted
    
    
    
    @IBAction func pauseSession() {
        print("pause")
        if let session = session{
            healthStore?.pause(session)
        }
    }
    
    @IBAction func stopSession() {
        print("stop")
        if let session = session{
            healthStore?.end(session)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        healthStore = (WKExtension.shared().delegate as? ExtensionDelegate)?.healthStore
        
        setTitle("Title")
        
        startSession()
    }
    
    func startSession(){
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(configuration: configuration)
            
            session!.delegate = self
            healthStore?.start(session!)
        }
        catch let error as NSError {
            // Perform proper error handling here...
            fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
        }
    }
    
}

extension SessionInterfaceController: HKWorkoutSessionDelegate{
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session did fail with error: \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print(event)
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        print("Workout state changed from: \(fromState.rawValue) to: \(toState.rawValue)")
    }
}
