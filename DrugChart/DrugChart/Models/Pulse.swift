//
//  Pulse.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation
import FHIR
class Pulse : VitalSignBaseModel
{
    var pulseRate:Double
    
    override init()
    {
        pulseRate = 0.0
    }
    
    override func setCorrespondentDoubleValue(valueString: String) {
        pulseRate = (valueString as NSString!).doubleValue
    }
    
    override func FHIRResource() -> Resource? {
        let code = FHIRCode("O/E - pulse rate",  codeId: Constant.CODE_PULSE_RATE)
        let observation = Observation(code:code  , status: "final")
        observation.comments = associatedText
        observation.effectiveDateTime = FHIRDate(super.date)
        observation.valueQuantity = FHIRQuantity(stringValue, doubleQuantity: pulseRate, unit: "beats/min")
        return observation
    }
}