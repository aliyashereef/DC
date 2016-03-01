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
    private var strSystolic = ""
    private var strDiastolic = ""
    var stringValueSystolic:String
    {
        get
        {
            return strSystolic
        }
        set (newVal)
        {
            strSystolic = newVal
            systolic = (newVal as NSString!).doubleValue
        }
    }

    var stringValueDiastolic:String
    {
        get
        {
            return strDiastolic
        }
        set (newVal)
        {
            strDiastolic = newVal
            diastolic = (newVal as NSString!).doubleValue
        }
    }
    
    override init()
    {
        systolic = 0.0
        diastolic = 0.0
//        stringValueSystolic = ""
//        stringValueDiastolic = ""
    }
}