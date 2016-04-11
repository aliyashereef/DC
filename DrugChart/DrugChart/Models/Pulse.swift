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
        let valueQuantity = FHIRQuantity(stringValue, unit: "beats/min")
        return self.FHIRResource(code, associatedText: associatedText, effectiveDateTime: super.date, quantity: valueQuantity)
    }
}