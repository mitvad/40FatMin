//
//  TimerInterfaceController.swift
//  40FatMin
//
//  Created by Vadym on 812//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit

class CountdownTimerInterfaceController: WKInterfaceController{
    
// MARK: - Overridden Public Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let (workout, zone) = context as? (workout: Workout, pulseZone: PulseZone){
            self.workout = workout
            self.zone = zone
        }
        else if let (workout, program) = context as? (workout: Workout, program: WorkoutProgram){
            self.workout = workout
            self.program = program
        }
        else{
            print("Error: unable to understand context in TimerInterfaceController:awake")
            return
        }
        
        startAnimation()
    }
    
// MARK: - Private Properties
    
    fileprivate weak var workout: Workout!
    fileprivate weak var zone: PulseZone?
    fileprivate weak var program: WorkoutProgram?
    
// MARK: - Private Methods
    
    fileprivate func startAnimation(){
        animate(withDuration: 1.0){
            self.readyLabel.setHidden(false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0){
            self.readyLabel.setHidden(true)
            self.count3Label.setHidden(false)
            self.count3Label.setAlpha(0.0)
            
            self.animate(withDuration: 0.5){
                self.count3Label.setAlpha(1.0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0){
            self.count3Label.setHidden(true)
            self.count2Label.setHidden(false)
            self.count2Label.setAlpha(0.0)
            
            self.animate(withDuration: 0.5){
                self.count2Label.setAlpha(1.0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0){
            self.count2Label.setHidden(true)
            self.count1Label.setHidden(false)
            self.count1Label.setAlpha(0.0)
            
            self.animate(withDuration: 0.5){
                self.count1Label.setAlpha(1.0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0){
            self.count1Label.setHidden(true)
            
            self.animate(withDuration: 0.5){
                self.goLabel.setHidden(false)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6.0){
            self.goLabel.setHidden(true)
            
            self.startSession()
        }
    }
    
    fileprivate func startSession(){
        if let workoutSessionManager = (WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager{
            if let program = program{
                workoutSessionManager.reinit(workout: workout, workoutProgram: program)
            }
            else if let zone = zone{
                workoutSessionManager.reinit(workout: workout, pulseZone: zone)
            }
            else{
                return
            }
        }
        else{
            var workoutSessionManager: WorkoutSessionManager
            if let program = program{
                workoutSessionManager = WorkoutSessionManager(workout: workout, workoutProgram: program)
            }
            else if let zone = zone{
                workoutSessionManager = WorkoutSessionManager(workout: workout, pulseZone: zone)
            }
            else{
                return
            }
            
            (WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager = workoutSessionManager
        }
        
        WKInterfaceController.reloadRootControllers(withNames: ["SessionActions", "SessionInfo", "SessionZones"], contexts: ["SessionActions", "Session", "SessionZones"])
    }
    
// MARK: - IBOutlets
    
    @IBOutlet var readyLabel: WKInterfaceLabel!
    @IBOutlet var count3Label: WKInterfaceLabel!
    @IBOutlet var count2Label: WKInterfaceLabel!
    @IBOutlet var count1Label: WKInterfaceLabel!
    @IBOutlet var goLabel: WKInterfaceLabel!
}
