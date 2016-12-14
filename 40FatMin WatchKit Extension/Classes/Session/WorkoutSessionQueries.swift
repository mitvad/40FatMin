//
//  WorkoutSessionQueries.swift
//  40FatMin
//
//  Created by Vadym on 1312//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

class WorkoutSessionQueries{
    
// MARK: - Initializers
    
    init() {
        self.heartRateQuery = HeartRateQuery()
        self.distanceQuery = DistanceQuery()
        self.activeCaloriesQuery = ActiveCaloriesQuery()
    }
    
// MARK: - Public Properties
    
    private(set) var heartRateQuery: HeartRateQuery
    private(set) var distanceQuery: DistanceQuery
    private(set) var activeCaloriesQuery: ActiveCaloriesQuery
    
// MARK: - Public Methods
    
    func start(_ sessionStartDate: Date){
        heartRateQuery.start(sessionStartDate)
        distanceQuery.start(sessionStartDate)
        activeCaloriesQuery.start(sessionStartDate)
    }
    
    func stop(){
        heartRateQuery.stop()
        distanceQuery.stop()
        activeCaloriesQuery.stop()
    }
    
    func reset(){
        heartRateQuery.reset()
        distanceQuery.reset()
        activeCaloriesQuery.reset()
    }
}
