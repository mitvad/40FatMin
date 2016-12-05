//
//  WorkoutProgram.swift
//  40FatMin
//
//  Created by Vadym on 212//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

class WorkoutProgram{
    
// MARK: - Initializers
    
    init(title: String, parts: [WorkoutProgramPart]){
        self.title = title
        self.parts = parts
        
        if self.parts.isEmpty{
            self.parts.append(WorkoutProgramPart(pulseZoneType: .z0, duration: 0))
        }
    }
    
// MARK: - Public Properties
    
    var title: String
    var parts: [WorkoutProgramPart]
    
    lazy var duration: TimeInterval = { [unowned self] in
        var result: TimeInterval = 0
        
        for part in self.parts{
            result += part.duration
        }
        
        return result
    }()
    
// MARK: - Public Computed Properties
    
    var firstPart: WorkoutProgramPart{
        get{
            return parts[0]
        }
    }
    
}
