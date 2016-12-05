//
//  ZoneInterfaceController.swift
//  40FatMin
//
//  Created by Vadym on 2711//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit

class ZoneInterfaceController: WKInterfaceController{
    
// MARK: - Overridden Public Methods
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let (workout, zone) = context as? (workout: Workout, zone: PulseZone) else{
            print("Error: unable to understand context in ZoneInterfaceController:awake")
            return
        }
        
        self.workout = workout
        self.zone = zone
        
        if UserDefaults.standard.string(forKey: UserDefaults.KeyZoneSelectionScreen) == zone.type.rawValue{
            becomeCurrentPage()
        }
        
        initText()
    }
    
    override func didAppear() {
        UserDefaults.standard.setValue(zone.type.rawValue, forKey: UserDefaults.KeyZoneSelectionScreen)
    }
    
// MARK: - Private Properties
    
    fileprivate var workout: Workout!
    fileprivate var zone: PulseZone!
    
// MARK: - Private Methods
    
    fileprivate func initText(){
        setTitle("< \(NSLocalizedString("Zones", comment: "Pulse Zones"))")
        
        zoneTitleLabel.setTextColor(zone.type.backgroundColor)
        zoneTitleLabel.setText(zone.type.title)
        
        startButton.setBackgroundColor(zone.type.backgroundColor)
        
        let attributedTitle = NSAttributedString(string: NSLocalizedString("START", comment: "START button title"), attributes: [NSForegroundColorAttributeName: zone.type.textColor])
        
        startButton.setAttributedTitle(attributedTitle)
        
        zonePulseTitleLabel.setText(NSLocalizedString("Pulse:", comment: "Pulse title"))
        
        zonePulseRangeLabel.setTextColor(zone.type.backgroundColor)
        
        if zone.type == PulseZoneType.z0{
            zonePulseRangeLabel.setText(NSLocalizedString("Any Pulse", comment: "Any pulse that user want"))
        }
        else{
            zonePulseRangeLabel.setText(String(format: NSLocalizedString("%d-%d", comment: "Zone pulse range"), Int(zone.range.lowerBound), Int(zone.range.upperBound)))
        }
    }
    
// MARK: - IBOutlets
    
    @IBOutlet var zoneTitleLabel: WKInterfaceLabel!
    @IBOutlet var zonePulseTitleLabel: WKInterfaceLabel!
    @IBOutlet var zonePulseRangeLabel: WKInterfaceLabel!
    @IBOutlet var startButton: WKInterfaceButton!
    
// MARK: - IBActions
    
    @IBAction func startSession() {
        (WKExtension.shared().delegate as? ExtensionDelegate)?.workoutSessionManager = WorkoutSessionManager(workout: workout, pulseZone: zone)
        
        WKInterfaceController.reloadRootControllers(withNames: ["SessionActions", "SessionInfo", "SessionZones"], contexts: ["SessionActions", "Session", "SessionZones"])
    }
    
}
