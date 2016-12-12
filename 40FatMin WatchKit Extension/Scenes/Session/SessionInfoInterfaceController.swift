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

        initText()
        
        becomeCurrentPage()
        
        observerShowSessionInfo = NotificationCenter.default.addObserver(forName: Notification.Name.ShowSessionInfoInterfaceController, object: nil, queue: nil, using: { [unowned self] (notification) in self.becomeCurrentPage()})
        
        workoutSessionManager.multicastDelegate.addDelegate(self)
        
        workoutSessionManager.startSession()
        
        updatePulseZone(workoutSessionManager.currentPulseZone)
        updateProgramParts()
        updateHeartRate(0.0)
        updateDistance(0.0)
    }
    
// MARK: - Private Properties

    fileprivate var observerShowSessionInfo: Any?
    
    fileprivate var currentProgramPartGroup: (passed: WKInterfaceGroup, leftover: WKInterfaceGroup, width: CGFloat)?
    
    fileprivate var messageIsOnScreen: Bool = false
    
// MARK: - Private Computed Properties
    
    fileprivate var workoutSessionManager: WorkoutSessionManager{
        get{
            return ((WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager)!
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
        
        congratulationLabel.setHidden(true)
    }
    
    fileprivate func updatePulseZone(_ pulseZone: PulseZone){
        hideMessage(true, isAnimate: false)
        
        animate(withDuration: 0.7){
            self.pulseZoneGroup.setBackgroundImage(pulseZone.type.backgroundImage)
            self.pulseZoneTitleLabel.setTextColor(pulseZone.type.textColor)
            self.pulseZoneLowerLabel.setTextColor(pulseZone.type.backgroundColor)
            self.pulseZoneUpperLabel.setTextColor(pulseZone.type.backgroundColor2)
            
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
                    
                    group.setBackgroundImage(program.parts[partIndex].pulseZoneType.backgroundImage)
                    
                    if program.parts[partIndex] === currentProgramPart{
                        let width = contentFrame.width * CGFloat(program.parts[partIndex].duration) / CGFloat(program.duration)
                        
                        group.setWidth(width)
                        group.setAlpha(alpha)
                        
                        alpha = CGFloat(0.6)
                        
                        if let currentGroupLeftover = partGroups[groupIndex + 1]{
                            currentGroupLeftover.setHidden(false)
                            currentGroupLeftover.setBackgroundImage(program.parts[partIndex].pulseZoneType.backgroundImage)
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
        
        let sessionDuration = Date().timeIntervalSince(workoutSessionManager.sessionStartDate)
        let passedTime = sessionDuration - currentProgramPart.startTime
        let passedWidth = currentProgramPartGroup.width * CGFloat(passedTime) / CGFloat(currentProgramPart.duration)
        
        animate(withDuration: 2.3){
            currentProgramPartGroup.passed.setWidth(passedWidth)
            currentProgramPartGroup.leftover.setWidth(currentProgramPartGroup.width - passedWidth)
        }
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
        sessionTimer.setDate(sessionStartDate)
        sessionTimer.start()
        
        content.setAlpha(1.0)
        
        updateCurrentProgramPart()
    }
    
    fileprivate func sessionDidStop(){
        sessionTimer.stop()
        
        updateHeartRate(0.0)
        
        content.setAlpha(0.6)
    }
    
    fileprivate func heartRateIsOutOfPulseZoneRange(_ isOut: Bool, _ isAbove: Bool, _ actualPulseZone: PulseZone?){
        if isOut && !messageIsOnScreen{
            if isAbove{
                self.messageLabel.setText(NSLocalizedString("Slow Down!", comment: "Short message text when the pulse is above the current pulse zone"))
            }
            else{
                self.messageLabel.setText(NSLocalizedString("Sped Up!", comment: "Short message text when the pulse is lower the current pulse zone"))
            }
            
            hideMessage(false, isAnimate: true)
            animatePulseZone(actualPulseZone)
        }
        else if !isOut && messageIsOnScreen{
            hideMessage(true, isAnimate: false)
        }
        else if isOut && messageIsOnScreen{
            if isAbove{
                self.messageLabel.setText(NSLocalizedString("Slow Down!", comment: "Short message text when the pulse is above the current pulse zone"))
            }
            else{
                self.messageLabel.setText(NSLocalizedString("Sped Up!", comment: "Short message text when the pulse is lower the current pulse zone"))
            }
            
            animateMessage()
            animatePulseZone(actualPulseZone)
        }
    }
    
    fileprivate func animatePulseZone(_ actualPulseZone: PulseZone?){
        guard let actualPulseZone = actualPulseZone else {return}
        guard actualPulseZone != workoutSessionManager.currentPulseZone else {return}
        
        for phase in 0..<3{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(phase) + 0.4){
                self.animate(withDuration: 0.2){
                    self.pulseZoneGroup.setBackgroundImage(actualPulseZone.type.backgroundImage)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(phase) + 1.0){
                self.animate(withDuration: 0.4){
                    self.pulseZoneGroup.setBackgroundImage(self.workoutSessionManager.currentPulseZone.type.backgroundImage)
                }
            }
        }
    }
    
    fileprivate func animateMessage(){
        for phase in 0..<3{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(phase)){
                self.animate(withDuration: 0.4){
                    self.messageLabel.setAlpha(0.0)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(phase) + 0.4){
                self.animate(withDuration: 0.2){
                    self.messageLabel.setAlpha(1.0)
                }
            }
        }
    }
    
    fileprivate func hideMessage(_ isHidden: Bool, isAnimate: Bool){
        messageIsOnScreen = !isHidden
        
        self.programInformationGroup.setHidden(!isHidden)
        self.messageLabel.setHidden(isHidden)
        
        if isAnimate{
            animateMessage()
        }
    }
    
    fileprivate func programDidFinish(){
        let randIndex = Int.random(1...3)
        var congratulationString: String
        
        switch randIndex {
        case 1:
            congratulationString = NSLocalizedString("You did it!", comment: "Short congratulation text 1")
        case 2:
            congratulationString = NSLocalizedString("Well done!", comment: "Short congratulation text 2")
        case 3:
            congratulationString = NSLocalizedString("Good job!", comment: "Short congratulation text 3")
        default:
            congratulationString = NSLocalizedString("You did it!", comment: "Short congratulation text 1")
        }
        
        self.congratulationLabel.setText(congratulationString)
        
        animate(withDuration: 1.0){
            self.congratulationLabel.setHidden(false)
            self.allParts.setHidden(true)
        }
        
        let when = DispatchTime.now() + 5.0
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.congratulationLabel.setText(NSLocalizedString("Completed!", comment: "Short congratulation text (permanently shown after random initial text)"))
            self.congratulationLabel.setHidden(true)
            
            self.animate(withDuration: 0.7, animations: {
                self.congratulationLabel.setHidden(false)
            })
        }
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
    
    @IBOutlet var congratulationLabel: WKInterfaceLabel!
    
    @IBOutlet var programInformationGroup: WKInterfaceGroup!
    
    @IBOutlet var messageLabel: WKInterfaceLabel!
    
// MARK: - Deinit
    
    deinit {
        if let observerShowSessionInfo = observerShowSessionInfo{
            NotificationCenter.default.removeObserver(observerShowSessionInfo)
        }
    }
}

// MARK: - Extension WorkoutSessionManagerDelegate

extension SessionInfoInterfaceController: WorkoutSessionManagerDelegate{
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, pulseZoneDidChangeTo toPulseZone: PulseZone, from fromPulseZone: PulseZone) {
        
        updatePulseZone(toPulseZone)
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, programPartDidChangeTo toProgramPart: WorkoutProgramPart?) {
        
        updateProgramParts()
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, heartRateDidChangeTo toHeartRate: Double) {
        
        updateHeartRate(toHeartRate)
        
        updateCurrentProgramPart()
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
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, heartRateIsOutOfPulseZoneRange isOut: Bool, isAbovePulseZoneRange isAbove: Bool, actualPulseZone pulseZone: PulseZone?) {
        
        heartRateIsOutOfPulseZoneRange(isOut, isAbove, pulseZone)
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, programDidFinish success: Bool) {
        programDidFinish()
    }
}
