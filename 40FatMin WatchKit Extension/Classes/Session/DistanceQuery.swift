//
//  DistanceQuery.swift
//  40FatMin
//
//  Created by Vadym on 1312//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit

class DistanceQuery{
    
// MARK: - Public Properties
    
    var updateHandler: ((_ value: Double) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    private(set) var distanceTotal = 0.0
    
// MARK: - Public Methods
    
    func start(_ sessionStartDate: Date){
        initQuery(sessionStartDate)
    }
    
    func stop(){
        if let query = query{
            healthStore.stop(query)
            self.query = nil
        }
    }
    
    func reset(){
        distanceTotal = 0.0
    }
    
// MARK: - Private Properties
    
    fileprivate var unit = HKUnit(from: "m")
    fileprivate var query: HKAnchoredObjectQuery?
    
// MARK: - Private Computed Properties
    
    fileprivate var healthStore: HKHealthStore{
        get{
            return ((WKExtension.shared().delegate as? ExtensionDelegate)?.healthStore)!
        }
    }
    
// MARK: - Private Methods
    
    fileprivate func initQuery(_ sessionStartDate: Date){
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else {
            return
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: sessionStartDate, end: nil, options: .strictEndDate )
        
        query = HKAnchoredObjectQuery(type: quantityType,
                                              predicate: datePredicate,
                                              anchor: nil,
                                              limit: HKObjectQueryNoLimit)
        { [unowned self] (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateDistance(sampleObjects, error)
        }
        
        query!.updateHandler = { [unowned self] (query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateDistance(samples, error)
        }
        
        healthStore.execute(query!)
    }
    
    fileprivate func updateDistance(_ samples: [HKSample]?, _ error: Error?){
        guard error == nil else{
            print("Heart rate update error: \(error!.localizedDescription)")
            
            errorHandler?(error!)
            
            return
        }
        
        guard let distanceSamples = samples as? [HKQuantitySample] else {
            return
        }
        
        guard let sample = distanceSamples.first else{
            return
        }
        
        distanceTotal += sample.quantity.doubleValue(for: self.unit)
        
        print("updateDistance \(distanceTotal)")
        
        self.updateHandler?(distanceTotal)
    }
    
}
