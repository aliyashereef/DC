//
//  BloodPressure.swift
//  vitalsigns
//
//  Created by Noureen on 04/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import Foundation

class BloodPressure : VitalSignBaseModel
{
    var systolic:Double // systolic should be greater than diastolic
    var diastolic:Double
    
    
    override init()
    {
        systolic = 0.0
        diastolic = 0.0
    }
}