//
//  InterfaceController.swift
//  40FatMin WatchKit Extension
//
//  Created by Vadym on 2411//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var workoutsTable: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        setTitle("40 Fat Min")
        
        initWorkoutsTable()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        animateAlpha(from: 0.0, to: 1.0, withDuration: 0.3)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func willDisappear() {
        animateAlpha(from: 1.0, to: 0.0, withDuration: 0.2)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        presentController(withNames: ["Program", "Zones"], contexts: ["40 Fat Min", ""])
    }
    
    private func initWorkoutsTable(){
        workoutsTable.setRowTypes(["LastWorkout", "Workout"])
        
        let row0 = workoutsTable.rowController(at: 0) as! CellLastWorkout
        row0.workoutName.setText("Outdoor Run")
        row0.workoutLast.setText("Last: 3.45 km")
        row0.workoutDate.setText("17 May, 2016")
        
        let row1 = workoutsTable.rowController(at: 1) as! CellWorkout
        row1.workoutName.setText("Indoor Run")
    }
    
    private func animateAlpha(from alpha1: CGFloat, to alpha2: CGFloat, withDuration duration: TimeInterval){
        workoutsTable.setAlpha(alpha1)
        
        animate(withDuration: duration, animations: { [unowned self] in
            self.workoutsTable.setAlpha(alpha2)
        })
    }
}
