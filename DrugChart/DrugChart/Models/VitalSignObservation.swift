//
//  VitalSignObservation.swift
//  DrugChart
//
//  Created by Noureen on 12/11/2015.
//
//

import Foundation

class VitalSignObservation
{
    var bloodPressure:BloodPressure?
    var temperature:BodyTemperature?
    var bm:BowelMovement?
    var pulse:Pulse?
    var respiratiory:Respiratory?
    var spo2:SPO2?
    var date:NSDate
    
    init()
    {
        bloodPressure = nil
        temperature = nil
        bm = nil
        pulse = nil
        respiratiory = nil
        spo2 = nil
        date = NSDate()
    }
    
}