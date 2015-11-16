//
//  BodyTemperature.swift
//  vitalsigns
//
//  Created by Noureen on 01/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit


class BodyTemperature
{
    var unit:String
    var value:Double
    var date:NSDate = NSDate()
    init()
    {
        unit = "Farenheit"
        value = 0.0
    }
}