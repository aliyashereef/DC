//
//  VitalSignObservation.swift
//  DrugChart
//
//  Created by Noureen on 12/11/2015.
//
//

import Foundation
import FHIR
import CocoaLumberjack

class VitalSignObservation:VitalSignFHIRBase
{
    var bloodPressure:BloodPressure
    var temperature:BodyTemperature
    var pulse:Pulse
    var respiratory:Respiratory
    var spo2:SPO2
    var date:NSDate
    var additionalOxygen:Bool
    var isConscious:Bool?
    var calculateNews:Bool
    var newsScore:String
    
    
    // Comma Score
    var eyesOpen:KeyValue?
    var bestVerbalResponse:KeyValue?
    var bestMotorResponse:KeyValue?
    var pupilRight:KeyValue?
    var pupilLeft:KeyValue?
    var limbMovementArms:KeyValue?
    var limbMovementLegs:KeyValue?
    
    override init()
    {
        bloodPressure = BloodPressure()
        temperature = BodyTemperature()
        pulse = Pulse()
        respiratory = Respiratory()
        spo2 = SPO2()
        date = NSDate()
        additionalOxygen = false
        isConscious = nil
        calculateNews = false
        newsScore = "N/A"
        
        eyesOpen = nil
        bestVerbalResponse = nil
        bestMotorResponse = nil
        pupilLeft = nil
        pupilRight = nil
        limbMovementArms = nil
        limbMovementLegs = nil
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
    func getFormattedDate() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.stringFromDate(self.date)
    }
    
    func getFormattedDayoftheWeek() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.stringFromDate(self.date)
    }
    
    func getNews() ->String
    {
        var score :Int = 0
        var invalidResult:Bool = false
        var interimScore : Int
        if (respiratory.isValueEntered())
        {
            interimScore = getRepiratoryRating((respiratory.repiratoryRate))
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
        }
        else
        {
            invalidResult = true
        }
        
        if spo2.isValueEntered()
        {
            interimScore = getOxygenSaturationRating((spo2.spO2Percentage))
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
        }
        else
        {
            invalidResult = true
        }
        
        if temperature.isValueEntered()
        {
            interimScore = getTemperatureRating(temperature.value)
            if(interimScore == -1)
            {
                invalidResult = true
            }
           score += interimScore
        }
        else
        {
            invalidResult = true
        }
        
        if bloodPressure.isValueEntered()
        {
            interimScore = getBloodPressureRating(bloodPressure.systolic)
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
        }
        else
        {
            invalidResult = true
        }
        
        if pulse.isValueEntered()
        {
            interimScore = getHeartRateRating(pulse.pulseRate)
            if(interimScore == -1)
            {
                invalidResult = true
            }
            score += interimScore
           
        }
        else
        {
            invalidResult = true
        }
        
        
        score += additionalOxygen ? 2:0
        
        score += (isConscious != nil && isConscious! == false ) ? 3:0

        return invalidResult == true ? "N/A" : String(score)
    }

    func getBloodPressureReading() ->String
    {
        if(bloodPressure.isValueEntered())
        {
            return bloodPressure.stringValueSystolic + "/" + bloodPressure.stringValueDiastolic
        }
        else
        {
            return " "
        }
    }
    func getSpo2Reading() -> String
    {
        if(spo2.isValueEntered())
        {
            return spo2.stringValue
        }
        else
        {
            return " "
        }
    }
    func getPulseReading() -> String
    {
        if(pulse.isValueEntered())
        {
            return pulse.stringValue
        }
        else
        {
            return " "
        }
    }
    func getRespiratoryReading() -> String
    {
        if respiratory.isValueEntered()
        {
            return respiratory.stringValue
        }
        else
        {
            return " "
        }
    }
    func setRespiratoryReading(value:Double )
    {
        if respiratory.isValueEntered()
        {
            respiratory = Respiratory()
        }
        respiratory.repiratoryRate = value
    }
    
    func getTemperatureReading() -> String
    {
        if temperature.isValueEntered()
        {
            return temperature.stringValue
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
    
    func asJSON() -> String
    {
        let bundle = Bundle(type:"transaction")
        bundle.entry =  [BundleEntry]()
        
        if(self.respiratory.isValueEntered() )
        {
            let entry = BundleEntry(json: nil)
            entry.resource = self.respiratory.FHIRResource()
            bundle.entry?.append(entry)
        }
        if(self.spo2.isValueEntered())
        {
            let entry = BundleEntry(json: nil)
            entry.resource = self.spo2.FHIRResource()
            bundle.entry?.append(entry)
        }
        if(self.temperature.isValueEntered())
        {
            let entry = BundleEntry(json: nil)
            entry.resource = self.temperature.FHIRResource()
            bundle.entry?.append(entry)
        }
        if(self.bloodPressure.isValueEntered())
        {
            let entry = BundleEntry(json: nil)
            entry.resource = self.bloodPressure.FHIRResource()
            bundle.entry?.append(entry)
        }
        if(self.pulse.isValueEntered())
        {
            let entry = BundleEntry(json: nil)
            entry.resource = self.pulse.FHIRResource()
            bundle.entry?.append(entry)
        }
        if(self.additionalOxygen)
        {
            let entry = BundleEntry(json:nil)
            let code = super.FHIRCode("", codeId: Constant.CODE_ADDITIONAL_OXYGEN)
            entry.resource = self.FHIRResource(code, associatedText: "", effectiveDateTime: self.date)
            bundle.entry?.append(entry)
        }
        if(self.isConscious != nil)
        {
            if(self.isConscious!)
            {
                let entry = BundleEntry(json:nil)
                let code = super.FHIRCode("", codeId: Constant.CODE_AVPU)
                let quantity = self.FHIRQuantity("0",  unit: "")
                entry.resource = self.FHIRResource(code, associatedText: "", effectiveDateTime: self.date , quantity: quantity)
                bundle.entry?.append(entry)
            }
            else
            {
                let entry = BundleEntry(json:nil)
                let code = super.FHIRCode("", codeId: Constant.CODE_AVPU)
                let quantity = self.FHIRQuantity("1", unit: "")
            entry.resource = self.FHIRResource(code, associatedText: "", effectiveDateTime: self.date, quantity: quantity)
                bundle.entry?.append(entry)
            }
        }
        if(calculateNews)
        {
            let newsScrore = getNews()
            if(newsScrore != "N/A")
            {
                let entry = BundleEntry(json:nil)
                let code = super.FHIRCode("", codeId: Constant.CODE_AVPU)
                let quantity = self.FHIRQuantity(newsScrore,  unit: "")
                entry.resource = self.FHIRResource(code, associatedText: "", effectiveDateTime: self.date , quantity: quantity)
                bundle.entry?.append(entry)
            }
        }
      //  print(bundle.asJSONString())
        
        return bundle.asJSONString()
    }
}