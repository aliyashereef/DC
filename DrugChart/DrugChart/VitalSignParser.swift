//
//  BundleParser.swift
//  DrugChart
//
//  Created by Noureen on 05/02/2016.
//
//

import Foundation
import FHIR
import AFNetworking
import CocoaLumberjack

class VitalSignParser : FhirParser
{
   
//    func getVitalSignsObservations(apiURL:String , onSuccess:(observationList:[VitalSignObservation])->Void)
//    {
//        super.connectServer(apiURL){(json:FHIRJSON? , error:NSError? ) in
//            if(error == nil) //so there is no error and the json can be parsed now.
//            {
//                var lstObservation = [VitalSignObservation]()
//                if let path = NSBundle.mainBundle().pathForResource("observation", ofType: "json" ) as String!
//                {
//                    let bundle = try! Bundle.instantiateFromPath(path)
//                    for bundleEntry in bundle.entry!
//                    {
//                        let obs = bundleEntry.resource as! Observation
//                        if(obs.code?.coding?.count == 0)
//                        {
//                            DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) ignoring the observation because code is not found")
//                            continue
//                        }
//                        let object = self.getObservation(obs)
//                        if(object == nil)
//                        {
//                            continue
//                        }
//                        
//                        let obsVitalSign:VitalSignObservation
//                        let dateToSearch = (object as? VitalSignBaseModel)?.date
//                        
//                        print (dateToSearch)
//                        
//                        let calendar = NSCalendar.currentCalendar()
//                        let chosenDateComponents = calendar.components([.Month , .Year , .Day , .Hour , .Minute], fromDate: dateToSearch!)
//                        
//                        let filteredObservations = lstObservation.filter { (observationList) -> Bool in
//                            let components = calendar.components([.Month, .Year, .Day , .Hour , .Minute], fromDate:observationList.date)
//                            return components.month == chosenDateComponents.month && components.year == chosenDateComponents.year &&  components.day == chosenDateComponents.day &&  components.hour == chosenDateComponents.hour && components.minute == chosenDateComponents.minute
//                        }
//                        if(filteredObservations.count > 0)
//                        {
//                            obsVitalSign = filteredObservations[0]
//                        }
//                        else
//                        {
//                            obsVitalSign = VitalSignObservation()
//                            obsVitalSign.date = dateToSearch!
//                            lstObservation.append(obsVitalSign)
//                        }
//                        if(object.isKindOfClass(Respiratory))
//                        {
//                            obsVitalSign.respiratory = object as? Respiratory
//                        }
//                        else if(object.isKindOfClass(BodyTemperature))
//                        {
//                            obsVitalSign.temperature = object as? BodyTemperature
//                        }
//                        else if(object.isKindOfClass(SPO2))
//                        {
//                            obsVitalSign.spo2 = object as? SPO2
//                        }
//                        else if(object.isKindOfClass(BloodPressure))
//                        {
//                            obsVitalSign.bloodPressure = object as? BloodPressure
//                        }
//                        else if(object.isKindOfClass(Pulse))
//                        {
//                            obsVitalSign.pulse = object as? Pulse
//                        }
//                    }
//                }
//                onSuccess(observationList: lstObservation)
//            }
//    }
//    }
    
    var CARE_RECORD_URL = "patients/%@/carerecord/observations?CodeValues=%@&StartDateTime=%@&EndDateTime=%@&IncludeMostRecent=%@"
    

    func getVitalSignsObservations(patientId:String, commaSeparatedCodes:String, startDate:NSDate, endDate:NSDate , includeMostRecent:Bool , onSuccess:(observationList:[VitalSignObservation])->Void)
    {
        let url = String(format:CARE_RECORD_URL , patientId , commaSeparatedCodes , startDate.getFHIRDateandTime() , endDate.getFHIRDateandTime(), includeMostRecent == true ?"true":"false")
        
        super.connectServer(url){(json:FHIRJSON? , error:NSError? ) in
            var lstObservation = [VitalSignObservation]()
            if(error == nil) //so there is no error and the json can be parsed now.
            {
                let bundle = Bundle(json: json)
                if(bundle.entry?.count > 0)
                {
                for bundleEntry in bundle.entry!
                    {
                        let obs = bundleEntry.resource as! Observation
                        if(obs.code?.coding?.count == 0)
                        {
                            DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) ignoring the observation because code is not found")
                            continue
                        }
                        let object = self.getObservation(obs)
                        if(object == nil)
                        {
                            continue
                        }
                        let obsVitalSign:VitalSignObservation
                        let dateToSearch = (object as? VitalSignBaseModel)?.date
                        let calendar = NSCalendar.currentCalendar()
                        let chosenDateComponents = calendar.components([.Month , .Year , .Day , .Hour , .Minute], fromDate: dateToSearch!)
                        
                        let filteredObservations = lstObservation.filter { (observationList) -> Bool in
                            let components = calendar.components([.Month, .Year, .Day , .Hour , .Minute], fromDate:observationList.date)
                            return components.month == chosenDateComponents.month && components.year == chosenDateComponents.year &&  components.day == chosenDateComponents.day &&  components.hour == chosenDateComponents.hour && components.minute == chosenDateComponents.minute
                        }
                        if(filteredObservations.count > 0)
                        {
                            obsVitalSign = filteredObservations[0]
                        }
                        else
                        {
                            obsVitalSign = VitalSignObservation()
                            obsVitalSign.date = dateToSearch!
                            lstObservation.append(obsVitalSign)
                        }
                        if(object.isKindOfClass(Respiratory))
                        {
                            obsVitalSign.respiratory = object as? Respiratory
                        }
                        else if(object.isKindOfClass(BodyTemperature))
                        {
                            obsVitalSign.temperature = object as? BodyTemperature
                        }
                        else if(object.isKindOfClass(SPO2))
                        {
                            obsVitalSign.spo2 = object as? SPO2
                        }
                        else if(object.isKindOfClass(BloodPressure))
                        {
                            obsVitalSign.bloodPressure = object as? BloodPressure
                        }
                        else if(object.isKindOfClass(Pulse))
                        {
                            obsVitalSign.pulse = object as? Pulse
                        }
                }
                }
                onSuccess(observationList: lstObservation)
            }
            else // this is error condition
            {
                onSuccess(observationList: lstObservation) //Currently the error get logged into the logger but if we have to show the error on main UI then we porbably need to pass the error from here.
            }
        }
    }
    
    func getObservation(obs:Observation)->AnyObject!
    {
        if(obs.effectiveDateTime == nil)
        {
            DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) ignoring the observation because datetime is not found")
            return nil
        }
        if(obs.effectiveDateTime?.time == nil)
        {
            DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) ignoring the observation because time is not found")
            return nil
        }
        let observationDate = obs.effectiveDateTime?.nsDate
        if(obs.code?.coding?.count == 0)
        {
            DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) ignoring the observation because code is not found")
            return nil
        }
      let code = obs.code?.coding![0]
      switch(code!.code!)
      {
        case Constant.CODE_RESPIRATORY_RATE:// -- respiratory rate
            let obsRespiratory = Respiratory()
            obsRespiratory.date = observationDate!
            obsRespiratory.repiratoryRate = obs.valueQuantity!.value!.doubleValue
            obsRespiratory.stringValue = (obs.valueQuantity?.stringValue)!
            return obsRespiratory
        case Constant.CODE_OXYGEN_SATURATION:// -- oxygen saturation
            let obsSPO2 = SPO2()
            obsSPO2.date = observationDate!
            obsSPO2.spO2Percentage = obs.valueQuantity!.value!.doubleValue
            obsSPO2.stringValue = (obs.valueQuantity?.stringValue)!
        return obsSPO2
        case Constant.CODE_ORAL_TEMPERATURE:// -- oral temperature
             let obsTemperature = BodyTemperature()
             obsTemperature.date = observationDate!
             obsTemperature.value = obs.valueQuantity!.value!.doubleValue
             obsTemperature.stringValue = (obs.valueQuantity?.stringValue)!
            return obsTemperature
        case Constant.CODE_BLOOD_PRESSURE:// -- blood presure
            let obsBloodPressure = BloodPressure()
            obsBloodPressure.date = observationDate!
            for component in obs.component!
            {
                let code = component.code?.coding![0]
                switch(code!.code!)
                {
                    case Constant.CODE_SYSTOLIC_READING: // systolic
                        obsBloodPressure.systolic = (component.valueQuantity?.value?.doubleValue)!
                        obsBloodPressure.stringValueSystolic = (component.valueQuantity?.value?.stringValue)!
                    case Constant.CODE_DIASTOLIC_READING : // diastolic
                        obsBloodPressure.diastolic = (component.valueQuantity?.value?.doubleValue)!
                    obsBloodPressure.stringValueDiastolic = (component.valueQuantity?.value?.stringValue)!
                    default:
                        DDLogError("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) Unexpected type \(obs.text) found in blood pressure components.")
                }
            }
            return obsBloodPressure
        case Constant.CODE_PULSE_RATE:// -- pulse rate
            let obsPulse = Pulse()
            obsPulse.date = observationDate!
            obsPulse.pulseRate = obs.valueQuantity!.value!.doubleValue
            obsPulse.stringValue = (obs.valueQuantity?.stringValue)!
            return obsPulse
      default:
            return nil
      }
    }
    
}