//
//  MulticastDelegate.swift
//  40FatMin
//
//  Created by Vadym on 812//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

class MulticastDelegate<T: AnyObject>{
    
// MARK: - Initializers
    
    init(weakReferences: Bool = true){
        self.delegates = weakReferences ? NSHashTable<T>.weakObjects() : NSHashTable<T>()
    }
    
// MARK: - Public Methods
    
    func addDelegate(_ delegate: T){
        delegates.add(delegate)
    }
    
    func removeDelegate(_ delegate: T){
        delegates.remove(delegate)
    }
    
    func removeAllDelegates(){
        delegates.removeAllObjects()
    }
    
    func contains(_ delegate: T) -> Bool{
        return delegates.contains(delegate)
    }
    
    func invoke(_ invocation: (T) -> Void){
        for delegate in delegates.allObjects{
            invocation(delegate)
        }
    }
    
// MARK: - Private Properties
    
    private let delegates: NSHashTable<T>
}
