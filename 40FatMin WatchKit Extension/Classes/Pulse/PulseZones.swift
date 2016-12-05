//
//  PulseZones.swift
//  40FatMin
//
//  Created by Vadym on 212//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

class PulseZones{
    
// MARK: - Initializers
    
    init(pulseZonesData: Data?) {
        readPulseZones(pulseZonesData)
    }
    
// MARK: - Public Properties
    
    var zones = [PulseZoneType: PulseZone]()
  
// MARK: - Public Methods
    
    func pulseZone(forType pulseZoneType: PulseZoneType) -> PulseZone{
        if let result = zones[pulseZoneType]{
            return result
        }
        print("Error: cannot find pulse zone for type=\(pulseZoneType)")
        return PulseZone.Z0
    }
    
// MARK: - Private Methods
    
    fileprivate func readPulseZones(_ data: Data?){
        guard let pulseZonesData = data else{
            print("Error: pulseZonesData = nil")
            return
        }
        
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: pulseZonesData, options: [])
            
            if let rootObject = jsonObject as? [String: Any]{
                if let zonesArray = rootObject["zones"] as? [[String: Any]]{
                    for zone in zonesArray{
                        guard let pulseZoneTypeString = zone["type"] as? String else{
                            print("Error: cannot read zone 'type' from JSON")
                            continue
                        }
                        
                        guard let pulseZoneType = PulseZoneType(rawValue: pulseZoneTypeString) else{
                            print("Error: cannot create PulseZoneType from type=\(pulseZoneTypeString)")
                            continue
                        }
                        
                        guard let lower = zone["lower"] as? Double else{
                            print("Error: cannot read zone 'lower' from JSON")
                            continue
                        }
                        
                        guard let upper = zone["upper"] as? Double else{
                            print("Error: cannot read zone 'upper' from JSON")
                            continue
                        }
                        
                        let pulseZone = PulseZone(pulseZoneType, pulsRange: lower...upper)
                        zones[pulseZoneType] = pulseZone
                    }
                }
            }
        }
        catch{
            print("Error: cannot read PulseZones from JSON")
        }
    }
}
