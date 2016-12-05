//
//  ProgramInterfaceController.swift
//  40FatMin
//
//  Created by Vadym on 2711//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit

class ProgramInterfaceController: WKInterfaceController{
    
// MARK: - Overridden Public Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let (workout, program) = context as? (workout: Workout, program: WorkoutProgram?) else{
            print("Error: unable to understand context in ProgramInterfaceController:awake")
            return
        }
        
        guard program != nil else{
            print("Error: program=nil in ProgramInterfaceController:awake")
            return
        }
        
        self.workout = workout
        self.program = program
        
        if UserDefaults.standard.string(forKey: UserDefaults.KeyProgramSelectionScreen) == self.program.title{
            becomeCurrentPage()
        }
        
        setTitle("< \(workout.title)")
        
        initText()
        initParts()
    }
    
    override func didAppear() {
        UserDefaults.standard.setValue(program.title, forKey: UserDefaults.KeyProgramSelectionScreen)
    }
    
// MARK: - Private Properties
    
    fileprivate var workout: Workout!
    fileprivate var program: WorkoutProgram!
    
// MARK: - Private Methods
    
    fileprivate func initText(){
        programTitleLabel.setText(program.title)
        
        startButton.setBackgroundColor(PulseZoneType.z2.backgroundColor)
        
        let attributedTitle = NSAttributedString(string: NSLocalizedString("START", comment: "START button title"), attributes: [NSForegroundColorAttributeName: PulseZoneType.z2.textColor])
        
        startButton.setAttributedTitle(attributedTitle)
        
        var durationText: String = "-"
        let hours: Int = Int(program.duration / 3600)
        let min: Int = (Int(program.duration) - (hours * 3600)) / 60
        
        if hours > 0{
            if min > 0{
                durationText = String(format: NSLocalizedString("%dh, %dmin", comment: "Workout program duration in hours and minutes"), hours, min)
            }
            else{
                durationText = String(format: NSLocalizedString("%dh", comment: "Workout program duration in hours"), hours)
            }
        }
        else if min > 0{
            durationText = String(format: NSLocalizedString("%dmin", comment: "Workout program duration in minutes"), min)
        }
        
        programDurationLabel.setText(durationText)
    }
    
    fileprivate func initParts(){
        let partGroups = [part1, part2, part3, part4, part5, part6, part7, part8, part9, part10]
        
        for (index, part) in partGroups.enumerated(){
            if let part = part{
                if program.parts.count > index{
                    part.setHidden(false)
                    
                    part.setWidth(contentFrame.width * CGFloat(program.parts[index].duration) / CGFloat(program.duration))
                    
                    part.setBackgroundColor(program.parts[index].pulseZoneType.backgroundColor)
                }
                else{
                    part.setHidden(true)
                }
            }
        }
    }
    
// MARK: - IBOutlets
    
    @IBOutlet var part1: WKInterfaceGroup!
    @IBOutlet var part2: WKInterfaceGroup!
    @IBOutlet var part3: WKInterfaceGroup!
    @IBOutlet var part4: WKInterfaceGroup!
    @IBOutlet var part5: WKInterfaceGroup!
    @IBOutlet var part6: WKInterfaceGroup!
    @IBOutlet var part7: WKInterfaceGroup!
    @IBOutlet var part8: WKInterfaceGroup!
    @IBOutlet var part9: WKInterfaceGroup!
    @IBOutlet var part10: WKInterfaceGroup!
    
    @IBOutlet var programTitleLabel: WKInterfaceLabel!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var programDurationLabel: WKInterfaceLabel!
    
// MARK: - IBActions
    
    @IBAction func startSession() {
        (WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager = WorkoutSessionManager(workout: workout, workoutProgram: program)
        
        WKInterfaceController.reloadRootControllers(withNames: ["SessionActions", "SessionInfo", "SessionZones"], contexts: ["SessionActions", "Session", "SessionZones"])
    }
    
}
