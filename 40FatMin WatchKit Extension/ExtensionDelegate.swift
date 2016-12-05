//
//  ExtensionDelegate.swift
//  40FatMin WatchKit Extension
//
//  Created by Vadym on 2411//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
// MARK: - Public Properties
    
    // Health Store single place initialization
    let healthStore = HKHealthStore()
    
    // All Model instances
    let workouts = Workouts()
    let pulseZones = PulseZones(pulseZonesData: AppFileManager.instance.getPulseZonesData())
    let workoutPrograms = WorkoutPrograms(workoutProgramsData: AppFileManager.instance.getWorkoutProgramsData())
    
    var workoutSessionManager: WorkoutSessionManager?
    
// MARK: - Public Methods

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        authorizeHealthKit()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
// MARK: - Private Methods
    
    private func authorizeHealthKit() {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is unavailable")
            return
        }
        
        let writableTypes: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKWorkoutType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        let readableTypes: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKWorkoutType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        // Request Authorization
        healthStore.requestAuthorization(toShare: writableTypes, read: readableTypes) { (success, error) in
            if success {
                print("Health Kit Authorization is successful!")
            } else {
                print("error authorizating HealthStore. \(error?.localizedDescription)")
            }
        }
    }
}
