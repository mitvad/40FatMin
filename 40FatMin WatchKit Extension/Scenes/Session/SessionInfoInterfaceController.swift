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
        
        guard let workoutSessionManager = self.workoutSessionManager else{
            print("Error: there is no workoutSessionManager")
            return
        }
        
        initText()
        
        becomeCurrentPage()
        
        observerShowSessionInfo = NotificationCenter.default.addObserver(forName: Notification.Name.ShowSessionInfoInterfaceController, object: nil, queue: nil, using: { [unowned self] (notification) in self.becomeCurrentPage()})
        
        workoutSessionManager.delegate = self
        
        workoutSessionManager.startSession()
        
        updatePulseZone()
        updateProgramParts()
        updateHeartRate(0.0)
        updateDistance(0)
    }
    
// MARK: - Private Properties
    
    fileprivate var workoutSessionManager: WorkoutSessionManager?
    
    fileprivate var observerShowSessionInfo: Any?
    
    fileprivate var currentProgramPartPassed: WKInterfaceGroup?
    fileprivate var currentProgramPartLeftover: WKInterfaceGroup?
    
// MARK: - Private Methods
    
    fileprivate func initText(){
        if let title = workoutSessionManager?.workoutProgram?.title{
            setTitle(title)
        }
        else{
            setTitle("")
        }
        
    }
    
    fileprivate func updatePulseZone(){
        guard let currentPulseZone = workoutSessionManager?.currentPulseZone else{
            print("Error: there is no currentPulseZone")
            return
        }
        
        pulseZoneGroup.setBackgroundColor(currentPulseZone.type.backgroundColor)
        pulseZoneTitleLabel.setTextColor(currentPulseZone.type.textColor)
        pulseZoneLowerLabel.setTextColor(currentPulseZone.type.backgroundColor)
        pulseZoneUpperLabel.setTextColor(currentPulseZone.type.backgroundColor)
        
        pulseZoneTitleLabel.setText(currentPulseZone.type.shortTitle)
        
        if currentPulseZone.type == PulseZoneType.z0{
            pulseZoneLowerLabel.setText("")
            pulseZoneUpperLabel.setText("")
        }
        else{
            pulseZoneLowerLabel.setText(String(Int(currentPulseZone.range.lowerBound)))
            pulseZoneUpperLabel.setText(String(Int(currentPulseZone.range.upperBound)))
        }
    }
    
    fileprivate func updateProgramParts(){
        guard let program = workoutSessionManager?.workoutProgram else{
            allParts.setHidden(true)
            return
        }
        
        guard let currentProgramPart = workoutSessionManager?.currentWorkoutProgramPart else{
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
                        
                        group.setWidth(width / 2)
                        group.setAlpha(alpha)
                        
                        alpha = CGFloat(0.5)
                        
                        partGroups[groupIndex + 1]?.setHidden(false)
                        partGroups[groupIndex + 1]?.setBackgroundColor(program.parts[partIndex].pulseZoneType.backgroundColor)
                        partGroups[groupIndex + 1]?.setWidth(width / 2)
                        partGroups[groupIndex + 1]?.setAlpha(alpha)
                        
                        groupIndex += 1
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
    
    fileprivate func updateHeartRate(_ heartRate: Double){
        if heartRate > 0{
            heartRateLabel.setTextColor(PulseZoneType.z4.backgroundColor)
            heartRateLabel.setText(String(Int(heartRate)))
            
            animateHeart()
        }
        else{
            heartRateLabel.setTextColor(UIColor.lightGray)
            heartRateLabel.setText("--")
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
        var measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        if Locale.current.usesMetricSystem == false{
            measurement.convert(to: UnitLength.yards)
            
            distanceUnitLabel.setText(NSLocalizedString("yd", comment: "Yard short name"))
        }
        
        if measurement.value < 100.0{
            distanceLabel.setText(String(format: "%.0f", measurement.value))
        }
        else{
            if Locale.current.usesMetricSystem == false{
                measurement.convert(to: UnitLength.miles)
                
                distanceUnitLabel.setText(NSLocalizedString("mi", comment: "Mile short name"))
            }
            else{
                measurement.convert(to: UnitLength.kilometers)
                
                distanceUnitLabel.setText(NSLocalizedString("km", comment: "Kilometer short name"))
            }
            
            distanceLabel.setText(String(format: "%.2f", measurement.value))
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
    
// MARK: - Deinit
    
    deinit {
        if let observerShowSessionInfo = observerShowSessionInfo{
            NotificationCenter.default.removeObserver(observerShowSessionInfo)
        }
        
        workoutSessionManager?.delegate = nil
    }
}

// MARK: - Extension WorkoutSessionManagerDelegate

extension SessionInfoInterfaceController: WorkoutSessionManagerDelegate{
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, pulseZoneDidChangeTo toPulseZone: PulseZone, from fromPulseZone: PulseZone) {
        
        updatePulseZone()
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, sessionDidChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, dateForTimer date: Date) {
        
        if toState == .running{
            sessionTimer.setDate(date)
            sessionTimer.start()
            
            content.setAlpha(1.0)
        }
        else if fromState == .running{
            sessionTimer.stop()
            
            updateHeartRate(0.0)
            
            content.setAlpha(0.6)
        }
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, heartRateDidChangeTo toHeartRate: Double) {
        
        updateHeartRate(toHeartRate)
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, distanceDidChangeTo toDistance: Double) {
        
        updateDistance(toDistance)
    }
}
