//
//  AppFileManager.swift
//  40FatMin
//
//  Created by Vadym on 312//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

class AppFileManager{
    
// MARK: - Type Properties
    
    static var instance = AppFileManager()
    
// MARK: - Initializers
    
    private init(){
        
    }
    
// MARK: - Public Methods
    
    func getWorkoutProgramsData() -> Data?{
        
        if let url = workoutProgramsURL{
            if let jsonData = try? Data(contentsOf: url){
                return jsonData
            }
        }
        
        if let url = Bundle.main.url(forResource: "DefaultWorkoutPrograms", withExtension: "json"){
            if let jsonData = try? Data(contentsOf: url){
                return jsonData
            }
        }
        
        return nil
    }
    
    func getPulseZonesData() -> Data?{
        
        if let url = pulseZonesURL{
            if let jsonData = try? Data(contentsOf: url){
                return jsonData
            }
        }
        
        if let url = Bundle.main.url(forResource: "DefaultPulseZones", withExtension: "json"){
            if let jsonData = try? Data(contentsOf: url){
                return jsonData
            }
        }
        
        return nil
    }
    
    @discardableResult
    func saveWorkoutProgramsData(jsonData: Data) -> Bool{
        
        if let url = workoutProgramsURL {
            do{
                try jsonData.write(to: url, options: [.atomic])
            }
            catch{
                print("Error: Cannot save WorkoutPrograms.json")
                
                return false
            }
        }
        
        return true
    }
    
    @discardableResult
    func savePulseZonesData(jsonData: Data) -> Bool{
        
        if let url = pulseZonesURL {
            do{
                try jsonData.write(to: url, options: [.atomic])
            }
            catch{
                print("Error: Cannot save PulseZones.json")
                
                return false
            }
        }
        
        return true
    }
    
// MARK: - Private Properties
    
    fileprivate lazy var workoutProgramsURL: URL? = {
        
        if let url = self.localDataDirectoryURL {
            let fileUrl = url.appendingPathComponent("WorkoutPrograms.json")
            return fileUrl
        }
        
        return nil
    }()
    
    fileprivate lazy var pulseZonesURL: URL? = {
        
        if let url = self.localDataDirectoryURL {
            let fileUrl = url.appendingPathComponent("PulseZones.json")
            return fileUrl
        }
        
        return nil
    }()
    
    fileprivate lazy var localDataDirectoryURL: URL? = {
        
        var error : NSError? = nil
        
        do {
            let url = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
            return url
        }
        catch var error1 as NSError {
            error = error1
            print("Error: Cannot create directory for storing local data, error: \(error)")
        }
        catch {
            fatalError()
        }
        
        return nil
    }()

}
