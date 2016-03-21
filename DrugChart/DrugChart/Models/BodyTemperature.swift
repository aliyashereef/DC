//
//  BodyTemperature.swift
//  vitalsigns
//
//  Created by Noureen on 01/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit
import FHIR

class BodyTemperature:VitalSignBaseModel
{
    var unit:String
    var value:Double
    override init()
    {
        unit = "Farenheit"
        value = 0.0
    }
    
    override func setCorrespondentDoubleValue(valueString: String) {
        value = (valueString as NSString!).doubleValue
    }
    
    override func FHIRResource() -> Resource? {
        let code = FHIRCode( "O/E - oral temperature taken",codeId: Constant.CODE_ORAL_TEMPERATURE)
        let valueQuantity = FHIRQuantity(stringValue,unit: "degrees C")
        return self.FHIRResource(code, associatedText: associatedText, effectiveDateTime: super.date, quantity: valueQuantity)
    }
}