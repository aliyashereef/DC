//
//  Respiratory.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation
import FHIR

class Respiratory:VitalSignBaseModel
{
    var repiratoryRate:Double
    override init()
    {
         repiratoryRate = 0.0
    }
    
    override func setCorrespondentDoubleValue(valueString: String) {
        repiratoryRate = (valueString as NSString!).doubleValue
    }
    
    override func FHIRResource() -> Resource? {
        let code = FHIRCode("O/E - respiratory rate",  codeId: Constant.CODE_RESPIRATORY_RATE)
        let observation = Observation(code:code  , status: "final")
        observation.comments = associatedText
        observation.effectiveDateTime = FHIRDate(super.date)
        observation.valueQuantity = FHIRQuantity(stringValue,  unit: "/minute")
        return observation
    }
}