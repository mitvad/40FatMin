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
        
        workoutSessionManager.multicastDelegate.addDelegate(self)
        
        content.setHidden(true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0){self.initContent()}
    }
    
// MARK: - Private Computed Properties
    
    fileprivate var workoutSessionManager: WorkoutSessionManager{
        get{
            return ((WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager)!
        }
    }
    
// MARK: - Private Methods
    
    fileprivate func initContent(){
        content.setHidden(false)
        
        initText()
    }
    
    fileprivate func initText(){
        if let title = workoutSessionManager.workoutProgram?.title{
             setTitle(title)
        }
        else{
            setTitle("")
        }
        stopButton.setBackgroundImage(UIImage(named: "stop-button"))
        
        updatePauseResumeButtonState()
    }
    
    fileprivate func updatePauseResumeButtonState(){
        if workoutSessionManager.sessionState == HKWorkoutSessionState.paused{
            pauseResumeButton.setBackgroundImage(UIImage(named: "resume-button"))
        }
        else if workoutSessionManager.sessionState == HKWorkoutSessionState.running{
            pauseResumeButton.setBackgroundImage(UIImage(named: "pause-button"))
        }
        else{
            pauseResumeButton.setBackgroundImage(nil)
        }
    }
    
    fileprivate func showSessionInfo(){
        NotificationCenter.default.post(Notification(name: NSNotification.Name.ShowSessionInfoInterfaceController))
    }
    
    
// MARK: - IBOutlets
    
    @IBOutlet var content: WKInterfaceGroup!
    
    @IBOutlet var pauseResumeButton: WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!
    
// MARK: - IBActions
    
    @IBAction func stop(){
        content.setHidden(true)
        
        workoutSessionManager.stopSession()
        
        if workoutSessionManager.shouldShowSummary{
            WKInterfaceController.reloadRootControllers(withNames: ["Summary"], contexts: [""])
        }
        else{
            WKInterfaceController.reloadRootControllers(withNames: ["Workouts"], contexts: [""])
        }
    }
    
    @IBAction func pauseResume(){
        if workoutSessionManager.sessionState == HKWorkoutSessionState.paused{
            workoutSessionManager.resumeSession()
        }
        else if workoutSessionManager.sessionState == HKWorkoutSessionState.running{
            workoutSessionManager.pauseSession()
        }
        
        showSessionInfo()
    }
}

extension SessionActionsInterfaceController: WorkoutSessionManagerDelegate{
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, sessionDidChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        updatePauseResumeButtonState()
    }
}
