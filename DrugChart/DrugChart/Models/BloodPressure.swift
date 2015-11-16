//
//  BloodPressure.swift
//  vitalsigns
//
//  Created by Noureen on 04/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import Foundation

class BloodPressure
{
    var systolic:Double // systolic should be greater than diastolic
    var diastolic:Double
    
    var date:NSDate = NSDate()
    
    init()
    {
        systolic = 0.0
        diastolic = 0.0
    }
}