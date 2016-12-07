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

class SessionInfoInterfaceController: WKInterfaceController{

// MARK: - Overridden Public Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.workoutSessionManager = (WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager
        
        guard workoutSessionManager != nil else{
            print("Error: there is no workoutSessionManager")
            return
        }
        
        initText()
        
        becomeCurrentPage()
        
        observerShowSessionInfo = NotificationCenter.default.addObserver(forName: Notification.Name.ShowSessionInfoInterfaceController, object: nil, queue: nil, using: { [unowned self] (notification) in self.becomeCurrentPage()})
        
        workoutSessionManager.delegate = self
        
        workoutSessionManager.startSession()
        
        updatePulseZone(workoutSessionManager.currentPulseZone)
        updateProgramParts()
        updateHeartRate(0.0)
        updateDistance(0.0)
    }
    
// MARK: - Private Properties
    
    fileprivate var workoutSessionManager: WorkoutSessionManager!
    
    fileprivate var observerShowSessionInfo: Any?
    
    fileprivate var currentProgramPartGroup: (passed: WKInterfaceGroup, leftover: WKInterfaceGroup, width: CGFloat)?
    
    fileprivate var sessionStartDate: Date?
    
// MARK: - Private Computed Properties
    
    fileprivate var isPulseZoneShouldChangeAutomatically: Bool{
        get{
            guard let currentProgramPart = workoutSessionManager.currentWorkoutProgramPart else {return false}
            guard let sessionStartDate = sessionStartDate else {return false}
            
            let sessionDuration = Date().timeIntervalSince(sessionStartDate)
            
            return !currentProgramPart.contains(time: sessionDuration)
        }
    }
    
// MARK: - Private Methods
    
    fileprivate func initText(){
        if let title = workoutSessionManager.workoutProgram?.title{
            setTitle(title)
        }
        else{
            setTitle("")
        }
    }
    
    fileprivate func updatePulseZone(_ pulseZone: PulseZone){
        animate(withDuration: 0.7){
            self.pulseZoneGroup.setBackgroundColor(pulseZone.type.backgroundColor)
            self.pulseZoneTitleLabel.setTextColor(pulseZone.type.textColor)
            self.pulseZoneLowerLabel.setTextColor(pulseZone.type.backgroundColor)
            self.pulseZoneUpperLabel.setTextColor(pulseZone.type.backgroundColor)
            
            self.pulseZoneTitleLabel.setText(pulseZone.type.shortTitle)
            
            if pulseZone.type == PulseZoneType.z0{
                self.pulseZoneLowerLabel.setText("")
                self.pulseZoneUpperLabel.setText("")
            }
            else{
                self.pulseZoneLowerLabel.setText(String(Int(pulseZone.range.lowerBound)))
                self.pulseZoneUpperLabel.setText(String(Int(pulseZone.range.upperBound)))
            }
        }
    }
    
    fileprivate func updateProgramParts(){
        guard let program = workoutSessionManager.workoutProgram else{
            allParts.setHidden(true)
            return
        }
        
        guard let currentProgramPart = workoutSessionManager.currentWorkoutProgramPart else{
            return
        }
        
        let partGroups = [part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11]
        
        var groupIndex = 0
        var partIndex = 0
        var alpha = CGFloat(1.0)
        while groupIndex < partGroups.count{
            if let group = partGroups[groupIndex]{
                if program.parts.count > partIndex{
                    
                    group.setHidden(false)
                    
                    group.setBackgroundColor(program.parts[partIndex].pulseZoneType.backgroundColor)
                    
                    if program.parts[partIndex] === currentProgramPart{
                        let width = contentFrame.width * CGFloat(program.parts[partIndex].duration) / CGFloat(program.duration)
                        
                        group.setWidth(width)
                        group.setAlpha(alpha)
                        
                        alpha = CGFloat(0.6)
                        
                        if let currentGroupLeftover = partGroups[groupIndex + 1]{
                            currentGroupLeftover.setHidden(false)
                            currentGroupLeftover.setBackgroundColor(program.parts[partIndex].pulseZoneType.backgroundColor)
                            currentGroupLeftover.setWidth(0)
                            currentGroupLeftover.setAlpha(alpha)
                            
                            currentProgramPartGroup = (passed: group, leftover: currentGroupLeftover, width: width)
                            
                            updateCurrentProgramPart()
                            
                            groupIndex += 1
                        }
                    }
                    else{
                        group.setWidth(contentFrame.width * CGFloat(program.parts[partIndex].duration) / CGFloat(program.duration))
                        
                        group.setAlpha(alpha)
                    }
                }
                else{
                    group.setHidden(true)
                }
            }
            
            groupIndex += 1
            partIndex += 1
        }
    }
    
    fileprivate func updateCurrentProgramPart(){
        guard let currentProgramPart = workoutSessionManager.currentWorkoutProgramPart else {return}
        guard let currentProgramPartGroup = currentProgramPartGroup else {return}
        guard let sessionStartDate = sessionStartDate else {return}
        
        let sessionDuration = Date().timeIntervalSince(sessionStartDate)
        let passedTime = sessionDuration - currentProgramPart.startTime
        let passedWidth = currentProgramPartGroup.width * CGFloat(passedTime) / CGFloat(currentProgramPart.duration)
        
        animate(withDuration: 2.3){
            currentProgramPartGroup.passed.setWidth(passedWidth)
            currentProgramPartGroup.leftover.setWidth(currentProgramPartGroup.width - passedWidth)
        }
    }
    
    fileprivate func changeCurrentProgramPart(){
        guard let program = workoutSessionManager.workoutProgram else {return}
        guard let sessionStartDate = sessionStartDate else {return}
        
        let sessionDuration = Date().timeIntervalSince(sessionStartDate)
        
        workoutSessionManager.currentWorkoutProgramPart = program.part(forTime: sessionDuration)
        
        updateProgramParts()
    }
    
    fileprivate func updateHeartRate(_ heartRate: Double){
        
        if heartRate > 0{
            animate(withDuration: 0.3){
                self.heartRateLabel.setTextColor(PulseZoneType.z4.backgroundColor)
                self.heartRateLabel.setText(String(Int(heartRate)))
            }
            
            animateHeart()
        }
        else{
            animate(withDuration: 0.3){
                self.heartRateLabel.setTextColor(UIColor.lightGray)
                self.heartRateLabel.setText("--")
            }
        }
    }
    
    fileprivate func animateHeart() {
        self.animate(withDuration: 0.5) {
            self.heartRateImage.setWidth(35)
            self.heartRateImage.setHeight(35)
        }
        
        let when = DispatchTime.now() + 0.5
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.animate(withDuration: 0.7, animations: {
                self.heartRateImage.setWidth(30)
                self.heartRateImage.setHeight(30)
            })
        }
    }
    
    fileprivate func updateDistance(_ distance: Double){
        var measurement = Measurement(value: distance / 1000, unit: UnitLength.kilometers)
        var valueString = ""
        var unitString = ""
        
        if Locale.current.usesMetricSystem == false{
            measurement.convert(to: UnitLength.miles)
        }
        
        if measurement.value < 0.10{
            if Locale.current.usesMetricSystem == false{
                measurement.convert(to: UnitLength.yards)
            }
            else{
                measurement.convert(to: UnitLength.meters)
            }
            
            valueString = String(format: "%.0f", measurement.value)
        }
        else{
            valueString = String(format: "%.2f", measurement.value)
        }
        
        switch measurement.unit {
        case UnitLength.kilometers:
            unitString = NSLocalizedString("km", comment: "Kilometer short name")
        case UnitLength.meters:
            unitString = NSLocalizedString("m", comment: "Meter short name")
        case UnitLength.miles:
            unitString = NSLocalizedString("mi", comment: "Mile short name")
        case UnitLength.yards:
            unitString = NSLocalizedString("yd", comment: "Yard short name")
        default:
            break
        }
        
        animate(withDuration: 0.3){
            self.distanceLabel.setText(valueString)
            self.distanceUnitLabel.setText(unitString)
        }
    }
    
    fileprivate func sessionDidStart(_ sessionStartDate: Date){
        self.sessionStartDate = sessionStartDate
        
        sessionTimer.setDate(sessionStartDate)
        sessionTimer.start()
        
        content.setAlpha(1.0)
        
        updateCurrentProgramPart()
    }
    
    fileprivate func sessionDidStop(){
        self.sessionStartDate = nil
        
        sessionTimer.stop()
        
        updateHeartRate(0.0)
        
        content.setAlpha(0.6)
    }
    
// MARK: - IBOutlets
    
    @IBOutlet var content: WKInterfaceGroup!
    
    @IBOutlet var sessionTimer: WKInterfaceTimer!
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    @IBOutlet var distanceUnitLabel: WKInterfaceLabel!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var heartRateImage: WKInterfaceImage!
    
    @IBOutlet var pulseZoneGroup: WKInterfaceGroup!
    @IBOutlet var pulseZoneTitleLabel: WKInterfaceLabel!
    @IBOutlet var pulseZoneUpperLabel: WKInterfaceLabel!
    @IBOutlet var pulseZoneLowerLabel: WKInterfaceLabel!
    
    @IBOutlet var allParts: WKInterfaceGroup!
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
    @IBOutlet var part11: WKInterfaceGroup!
    
// MARK: - Deinit
    
    deinit {
        if let observerShowSessionInfo = observerShowSessionInfo{
            NotificationCenter.default.removeObserver(observerShowSessionInfo)
        }
        
        if workoutSessionManager != nil{
            workoutSessionManager.delegate = nil
        }
    }
}

// MARK: - Extension WorkoutSessionManagerDelegate

extension SessionInfoInterfaceController: WorkoutSessionManagerDelegate{
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, pulseZoneDidChangeTo toPulseZone: PulseZone, from fromPulseZone: PulseZone) {
        
        updatePulseZone(toPulseZone)
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, heartRateDidChangeTo toHeartRate: Double) {
        
        updateHeartRate(toHeartRate)
        
        if isPulseZoneShouldChangeAutomatically{
            changeCurrentProgramPart()
        }
        else{
            updateCurrentProgramPart()
        }
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, distanceDidChangeTo toDistance: Double) {
        
        updateDistance(toDistance)
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, sessionDidChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        if toState == .running{
            sessionDidStart(date)
        }
        else if fromState == .running{
            sessionDidStop()
        }
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, programDidFinish success: Bool) {
        // do some notification to user
    }
}
