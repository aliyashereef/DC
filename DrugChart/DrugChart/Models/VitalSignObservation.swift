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
    
    var eyesOpen:KeyValue?
    var bestVerbalResponse:KeyValue?
    var bestMotorResponse:KeyValue?
    
    init()
    {
        bloodPressure = nil
        temperature = nil
        bm = nil
        pulse = nil
        respiratiory = nil
        spo2 = nil
        date = NSDate()
        eyesOpen = nil
        bestVerbalResponse = nil
        bestMotorResponse=nil
    }
    
    func getComaScore()  -> String
    {
        var score :Int = 0
        
        if eyesOpen != nil
        {
            score += (eyesOpen?.key)!
        }
        if bestVerbalResponse != nil
        {
            score += (bestVerbalResponse?.key)!
        }
        if bestMotorResponse != nil
        {
            score += (bestMotorResponse?.key)!
        }
        return score < 3 ? "N/A" : String(score)
    }
    
    func getNews() ->String
    {
        var score :Int = 0
        var invalidResult:Bool = true
        var foundValue:Bool = false
        var interimScore : Int
        if respiratiory != nil
        {
            interimScore = getRepiratoryRating((respiratiory?.repiratoryRate)!)
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
            foundValue = true
        }
        if spo2 != nil
        {
            interimScore = getOxygenSaturationRating((spo2?.spO2Percentage)!)
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
            foundValue = true
        }
        
        if temperature != nil
        {
            interimScore = getTemperatureRating((temperature?.value)!)
            if(interimScore == -1)
            {
                invalidResult = true
            }
           score += interimScore
           foundValue = true
        }
        
        if bloodPressure != nil
        {
            interimScore = getBloodPressureRating((bloodPressure?.systolic)!)
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
            foundValue = true
        }
        
        if pulse != nil
        {
            interimScore = getHeartRateRating((pulse?.pulseRate)!)
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
            foundValue = true
        }
        
        return foundValue==false || invalidResult == true ? "N/A" : String(score)
    }

    func getBloodPressureReading() ->String
    {
        if(bloodPressure != nil)
        {
            return String (bloodPressure?.systolic ) + "/" + String (bloodPressure?.diastolic)
        }
        else
        {
            return " "
        }
    }
    func getSpo2Reading() -> String
    {
        if(spo2 != nil)
        {
            return String (spo2?.spO2Percentage)
        }
        else
        {
            return " "
        }
    }
    func getPulseReading() -> String
    {
        if(pulse != nil)
        {
            return String(pulse?.pulseRate)
        }
        else
        {
            return " "
        }
    }
    func getRespiratoryReading() -> String
    {
        if respiratiory != nil
        {
            return String(respiratiory?.repiratoryRate)
        }
        else
        {
            return " "
        }
    }
    func getTemperatureReading() -> String
    {
        if temperature != nil
        {
            return String(temperature?.value)
        }
        else
        {
            return " "
        }
    }
    func getBMReading() -> String
    {
        if bm != nil
        {
            return String(bm?.value)
        }
        else
        {
            return " "
        }
    }
    func getHeartRateRating(value : Double) -> Int
    {
        if value <= 40 || value >= 131
        {
            return 3
        }
        else if (value >= 41 && value <= 50) || (value >= 91 && value <= 110)
        {
            return 1
        }
        else if value >= 51 && value <= 90
        {
            return 0
        }
        else if value >= 111 && value <= 130
        {
            return 2
        }
        else
        {
            return -1
        }
    }
    func getBloodPressureRating(value:Double) -> Int
    {
        if value <= 90 || value >= 220
        {
            return 3
        }
        else if value >= 91 && value <= 100
        {
            return 2
        }
        else if value >= 101 && value <= 110
        {
            return 1
        }
        else if value >= 111 && value <= 219
        {
            return 0
        }
        else
        {
            return -1
        }
    }
    
    func getTemperatureRating(value:Double) ->Int
    {
        if value <= 35.0
        {
            return 3
        }
        else if (value >= 35.1 && value <= 36.0) ||
        (value >= 38.1 && value <= 39.0)
        {
            return 1
        }
        else if value >= 36.1 && value <= 38.0
        {
            return 0
        }
        else if value >= 39.1
        {
            return 2
        }
        else
        {
            return -1
        }
    }
    func getOxygenSaturationRating(value:Double) -> Int
    {
        if value <= 91
        {
            return 3
        }
        else if value >= 92 && value <= 93
        {
            return 2
        }
        else if value >= 94 && value <= 95
        {
            return 1
        }
        else if value >= 96
        {
            return 0
        }
        else
        {
            return -1
        }
    }
    func getRepiratoryRating(value:Double) ->Int
    {
        if value <= 8 || value >= 25
        {
        return 3
        }
        else if (value >= 9 && value <= 11)
        {
            return 1
        }
        else if value >= 12 && value <= 20
        {
        return 0
        }
        else if value >= 21 && value <= 24
        {
            return 2
        }
        else
        {
            return -1
        }
    }
    
}