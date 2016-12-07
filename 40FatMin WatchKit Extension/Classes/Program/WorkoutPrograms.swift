//
//  WorkoutPrograms.swift
//  40FatMin
//
//  Created by Vadym on 212//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

class WorkoutPrograms{
    
// MARK: - Initializers
    
    init(workoutProgramsData: Data?){
        readWorkoutPrograms(workoutProgramsData)
    }
    
// MARK: - Public Properties
    
    var programs = [WorkoutProgram]()

// MARK: - Private Methods
    
    fileprivate func readWorkoutPrograms(_ data: Data?){
        guard let workoutProgramsData = data else{
            print("Error: workoutProgramsData = nil")
            return
        }
        
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: workoutProgramsData, options: [])
            
            if let rootObject = jsonObject as? [String: Any]{
                if let programsArray = rootObject["programs"] as? [[String: Any]]{
                    for program in programsArray{
                        guard let title = program["title"] as? String else{
                            print("Error: cannot read program 'title' from JSON")
                            continue
                        }
                        
                        guard let partsArray = program["parts"] as? [[String: Any]] else{
                            print("Error: cannot read program 'parts' from JSON")
                            continue
                        }
                        
                        var parts = [WorkoutProgramPart]()
                        
                        var startOffset = 0.0
                        
                        for part in partsArray{
                            guard let pulseZoneTypeString = part["zoneType"] as? String else{
                                print("Error: cannot read part 'type' from program=\(title)")
                                continue
                            }
                            
                            guard let pulseZoneType = PulseZoneType(rawValue: pulseZoneTypeString) else{
                                print("Error: cannot create PulseZoneType from type=\(pulseZoneTypeString) from program=\(title)")
                                continue
                            }
                            
                            guard let duration = part["duration"] as? Double else{
                                print("Error: cannot read part 'duration' from program=\(title)")
                                continue
                            }
                            
                            parts.append(WorkoutProgramPart(pulseZoneType: pulseZoneType, duration: duration, startTime: startOffset))
                            
                            startOffset += duration
                        }
                        
                        if !parts.isEmpty{
                            programs.append(WorkoutProgram(title: title, parts: parts))
                        }
                    }
                }
            }
        }
        catch{
            print("Error: cannot read WorkoutPrograms from JSON")
        }
    }
}
