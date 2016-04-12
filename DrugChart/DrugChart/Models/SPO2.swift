//
//  SPO2.swift
//  vitalsigns
//
//  Created by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation
import FHIR

class SPO2 : VitalSignBaseModel
{
    var spO2Percentage:Double
    
    override init()
    {
        spO2Percentage = 0.0
    }
    
    override func setCorrespondentDoubleValue(valueString: String) {
        spO2Percentage = (valueString as NSString!).doubleValue
    }
    
    override func FHIRResource() -> Resource? {
        let code = FHIRCode("Blood oxygen saturation",  codeId: Constant.CODE_OXYGEN_SATURATION)
        let valueQuantity = FHIRQuantity(stringValue,  unit: "%")
        return self.FHIRResource(code, associatedText: associatedText, effectiveDateTime: super.date, quantity: valueQuantity)
    }
}