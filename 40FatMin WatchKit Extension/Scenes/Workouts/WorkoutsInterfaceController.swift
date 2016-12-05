//
//  InterfaceController.swift
//  40FatMin WatchKit Extension
//
//  Created by Vadym on 2411//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import WatchKit
import Foundation


class WorkoutsInterfaceController: WKInterfaceController {

// MARK: - Overridden Public Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        workouts = (WKExtension.shared().delegate as? ExtensionDelegate)?.workouts
        
        setTitle("40 Fat Min")
        
        initWorkoutsTable()
    }
    
    override func willActivate() {
        super.willActivate()
        
        animateAlpha(from: 0.0, to: 1.0, withDuration: 0.3)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func willDisappear() {
        animateAlpha(from: 1.0, to: 0.0, withDuration: 0.2)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        guard let programs = (WKExtension.shared().delegate as? ExtensionDelegate)?.workoutPrograms.programs else{
            print("Error: there is no programs")
            return
        }
        
        // Program scenes
        var names = Array<String>.init(repeating: "Program", count: programs.count)
        
        // Zones scene
        names.append("Zones")
        
        let workout = workouts.allWorkouts[rowIndex]
        
        var contexts = Array<(workout: Workout, program: WorkoutProgram?)>()
        
        // Context for Program scenes
        for program in programs{
            contexts.append((workout: workout, program: program))
        }
        
        // Context for Zones scene
        contexts.append((workout: workout, program: nil))
        
        presentController(withNames: names, contexts: contexts)
    }
    
// MARK: - Private Properties
    
    fileprivate var workouts: Workouts!

// MARK: - Private Methods
    
    fileprivate func initWorkoutsTable(){
        let rowTypes = Array.init(repeating: "Workout", count: workouts.allWorkouts.count)
        
        workoutsTable.setRowTypes(rowTypes)
        
        for (index, workout) in workouts.allWorkouts.enumerated(){
            let row = workoutsTable.rowController(at: index) as! CellWorkout
            row.workoutName.setText(workout.title)
        }
    }
    
    fileprivate func animateAlpha(from alpha1: CGFloat, to alpha2: CGFloat, withDuration duration: TimeInterval){
        workoutsTable.setAlpha(alpha1)
        
        animate(withDuration: duration, animations: { [unowned self] in
            self.workoutsTable.setAlpha(alpha2)
        })
    }
    
// MARK: - IBOutlets
    
    @IBOutlet var workoutsTable: WKInterfaceTable!
    
}
