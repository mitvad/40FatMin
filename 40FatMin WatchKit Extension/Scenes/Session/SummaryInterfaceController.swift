//
//  SummaryInterfaceController.swift
//  40FatMin
//
//  Created by Vadym on 1312//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit

class SummaryInterfaceController: WKInterfaceController{
    
// MARK: - Overridden Public Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        initText()
    }
    
// MARK: - Private Computed Properties
    
    fileprivate var workoutSessionManager: WorkoutSessionManager{
        get{
            return ((WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager)!
        }
    }
    
// MARK: - Private Methods
    
    fileprivate func initText(){
        setTitle(NSLocalizedString("Summary", comment: "Summary scene title"))
        
        workoutLabel.setText(workoutSessionManager.workout.title)
        
        if let program = workoutSessionManager.workoutProgram{
            programLabel.setText(program.title)
        }
        else{
            programLabel.setText(NSLocalizedString("Zones", comment: "Pulse Zones"))
        }
        
        //
        
        workoutStartDateLabel.setText(DateFormatter.localizedString(from: workoutSessionManager.workoutStartDate(), dateStyle: .none, timeStyle: .short))
        
        workoutEndDateLabel.setText(DateFormatter.localizedString(from: workoutSessionManager.workoutEndDate(), dateStyle: .none, timeStyle: .short))
        
        //
        
        totalDistanceTitleLabel.setText(NSLocalizedString("TOTAL DISTANCE", comment: "Total distance title for Summary (prefered in uppercase)"))
        
        let localizedDistance = LocalizedDistance(workoutSessionManager.queries.distanceQuery.distanceTotal)
        totalDistanceValueLabel.setText(localizedDistance.value)
        totalDistanceUnitLabel.setText(localizedDistance.unit)
        
        //
        
        totalTimeTitleLabel.setText(NSLocalizedString("TOTAL TIME", comment: "Total time title for Summary (prefered in uppercase)"))
        totalTimeValueLabel.setDate(workoutSessionManager.sessionStartDate)
        
        //
        
        activeCaloriesTitleLabel.setText(NSLocalizedString("ACTIVE CALORIES", comment: "Active calories title for Summary (prefered in uppercase)"))
        activeCaloriesValueLabel.setText(String(format: "%.0f", workoutSessionManager.queries.activeCaloriesQuery.totalValue))
        activeCaloriesUnitLabel.setText(NSLocalizedString("CAL", comment: "Calories unit (short in uppercase)"))
        
    }
    
    fileprivate func goToWorkouts(){
        WKInterfaceController.reloadRootControllers(withNames: ["Workouts"], contexts: [""])
    }
    
// MARK: - IBOutlets
    
    @IBOutlet var workoutLabel: WKInterfaceLabel!
    @IBOutlet var programLabel: WKInterfaceLabel!
    
    @IBOutlet var workoutStartDateLabel: WKInterfaceLabel!
    @IBOutlet var workoutEndDateLabel: WKInterfaceLabel!
    
    @IBOutlet var totalDistanceTitleLabel: WKInterfaceLabel!
    @IBOutlet var totalDistanceValueLabel: WKInterfaceLabel!
    @IBOutlet var totalDistanceUnitLabel: WKInterfaceLabel!
    
    @IBOutlet var totalTimeTitleLabel: WKInterfaceLabel!
    @IBOutlet var totalTimeValueLabel: WKInterfaceTimer!
    
    @IBOutlet var activeCaloriesTitleLabel: WKInterfaceLabel!
    @IBOutlet var activeCaloriesValueLabel: WKInterfaceLabel!
    @IBOutlet var activeCaloriesUnitLabel: WKInterfaceLabel!
    
// MARK: - IBActions
    
    @IBAction func saveWorkout(){
        WKInterfaceDevice.current().play(.success)
        goToWorkouts()
    }
    
    @IBAction func discardWorkout(){
        goToWorkouts()
    }
}
