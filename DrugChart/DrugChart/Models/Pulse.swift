//
//  Pulse.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation

class Pulse : VitalSignBaseModel
{
    var pulseRate:Double
    
    override init()
    {
        pulseRate = 0.0
    }
}