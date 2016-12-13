//
//  UIUtil.swift
//  40FatMin
//
//  Created by Vadym on 1312//16.
//  Copyright © 2016 Vadym Mitin. All rights reserved.
//

import Foundation

func LocalizedDistance(_ distance: Double) -> (value: String, unit: String){
    var measurement = Measurement(value: distance / 1000, unit: UnitLength.kilometers)
    var valueString = ""
    var unitString = ""
    
    if Locale.current.usesMetricSystem == false{
        measurement.convert(to: UnitLength.miles)
    }
    
    if measurement.value < 0.10{
        if Locale.current.usesMetricSystem == false{
            measurement.convert(to: UnitLength.yards)
        }
        else{
            measurement.convert(to: UnitLength.meters)
        }
        
        valueString = String(format: "%.0f", measurement.value)
    }
    else{
        valueString = String(format: "%.2f", measurement.value)
    }
    
    switch measurement.unit {
    case UnitLength.kilometers:
        unitString = NSLocalizedString("km", comment: "Kilometer short name")
    case UnitLength.meters:
        unitString = NSLocalizedString("m", comment: "Meter short name")
    case UnitLength.miles:
        unitString = NSLocalizedString("mi", comment: "Mile short name")
    case UnitLength.yards:
        unitString = NSLocalizedString("yd", comment: "Yard short name")
    default:
        break
    }
    
    return (value: valueString, unit: unitString)
}
