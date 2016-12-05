//
//  SessionActionsInterfaceController.swift
//  40FatMin
//
//  Created by Vadym on 512//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit

class SessionActionsInterfaceController: WKInterfaceController{
    
// MARK: - Overridden Public Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        workoutSessionManager = (WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager
        
        initText()
    }
    
    override func willActivate(){
        updatePauseResumeButtonState()
    }

// MARK: - Private Properties
    
    fileprivate var workoutSessionManager: WorkoutSessionManager?
    
// MARK: - Private Methods
    
    fileprivate func initText(){
        if let title = workoutSessionManager?.workoutProgram?.title{
             setTitle(title)
        }
        else{
            setTitle("")
        }
        
        stopButton.setTitle(NSLocalizedString("Stop", comment: "Stop workout session (short button title)"))
        
        updatePauseResumeButtonState()
    }
    
    fileprivate func updatePauseResumeButtonState(){
        if workoutSessionManager?.sessionState == HKWorkoutSessionState.paused{
            setResumeTitle()
        }
        else if workoutSessionManager?.sessionState == HKWorkoutSessionState.running{
            setPauseTitle()
        }
        else{
            pauseResumeButton.setTitle("--")
        }
    }
    
    fileprivate func setPauseTitle(){
        pauseResumeButton.setTitle(NSLocalizedString("Pause", comment: "Pause workout session (short button title)"))
    }
    
    fileprivate func setResumeTitle(){
        pauseResumeButton.setTitle(NSLocalizedString("Resume", comment: "Resume workout session (short button title)"))
    }
    
    fileprivate func showSessionInfo(){
        NotificationCenter.default.post(Notification(name: NSNotification.Name.ShowSessionInfoInterfaceController))
    }
    
    
// MARK: - IBOutlets
    
    @IBOutlet var pauseResumeButton: WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!
    
// MARK: - IBActions
    
    @IBAction func stop(){
        workoutSessionManager?.stopSession()
        
        //TODO: show WorkoutSessionResult here
        WKInterfaceController.reloadRootControllers(withNames: ["Workouts"], contexts: [""])
    }
    
    @IBAction func pauseResume(){
        if workoutSessionManager?.sessionState == HKWorkoutSessionState.paused{
            workoutSessionManager?.resumeSession()
            
            setPauseTitle()
        }
        else if workoutSessionManager?.sessionState == HKWorkoutSessionState.running{
            workoutSessionManager?.pauseSession()
            
            setResumeTitle()
        }
        
        showSessionInfo()
    }
}
