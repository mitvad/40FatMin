//
//  Workouts.swift
//  40FatMin
//
//  Created by Vadym on 212//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import HealthKit

class Workouts{

// MARK: - Initializers
    
    init(){
        allWorkouts = []
        
        let configuration1 = HKWorkoutConfiguration()
        configuration1.activityType = HKWorkoutActivityType.running
        configuration1.locationType = .outdoor
        let workout1 = Workout(configuration: configuration1)
        allWorkouts.append(workout1)
        
        let configuration2 = HKWorkoutConfiguration()
        configuration2.activityType = HKWorkoutActivityType.running
        configuration2.locationType = .indoor
        let workout2 = Workout(configuration: configuration2)
        allWorkouts.append(workout2)
    }
    
// MARK: - Public Properties
    
    var allWorkouts: [Workout]

}
