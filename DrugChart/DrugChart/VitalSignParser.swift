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
   
    func getVitalSignsObservations(apiURL:String , onSuccess:(observationList:[VitalSignObservation])->Void)
    {
        super.connectServer(apiURL){(json:FHIRJSON? , error:NSError? ) in
            if(error == nil) //so there is no error and the json can be parsed now.
            {
                //let bundle = Bundle.init(json: json)
                //boc test
                var lstObservation = [VitalSignObservation]()
                if let path = NSBundle.mainBundle().pathForResource("observation", ofType: "json" ) as String!
                {
                    let bundle = try! Bundle.instantiateFromPath(path)
                    for bundleEntry in bundle.entry!
                    {
                        let obs = bundleEntry.resource as! Observation
                        if(obs.code?.coding?.count == 0)
                        {
                            DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) ignoring the observation because is not found")
                            continue
                        }
                        let obsVitalSign = VitalSignObservation()
                        obsVitalSign.date = NSDate()
                        let object = self.getObservation(obs)
                        if(object == nil)
                        {
                            continue
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
                       lstObservation.append(obsVitalSign)
                    }
                }
                onSuccess(observationList: lstObservation)
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
        case "253914014":// -- respiratory rate
            let obsRespiratory = Respiratory()
            obsRespiratory.date = observationDate!
            obsRespiratory.repiratoryRate = obs.valueQuantity!.value!.doubleValue
            return obsRespiratory
        case "1218970019":// -- oxygen saturation
            let obsSPO2 = SPO2()
            obsSPO2.date = observationDate!
            obsSPO2.spO2Percentage = obs.valueQuantity!.value!.doubleValue
        return obsSPO2
        case "402545016":// -- oral temperature
             let obsTemperature = BodyTemperature()
             obsTemperature.date = observationDate!
             obsTemperature.value = obs.valueQuantity!.value!.doubleValue
            return obsTemperature
        case "254063019":// -- blood presure
            return nil
        case "254020017":// -- pulse rate
            let obsPulse = Pulse()
            obsPulse.date = observationDate!
            obsPulse.pulseRate = obs.valueQuantity!.value!.doubleValue
            return obsPulse
      default:
            return nil
      }
    }
    
}