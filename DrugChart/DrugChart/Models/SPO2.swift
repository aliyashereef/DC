//
//  SPO2.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation
class SPO2 : VitalSignBaseModel
{
    var spO2Percentage:Double
    
    override init()
    {
        spO2Percentage = 0.0
    }
}