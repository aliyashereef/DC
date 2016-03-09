//
//  BloodPressure.swift
//  vitalsigns
//
//  Created by Noureen on 04/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import Foundation
import FHIR

class BloodPressure : VitalSignBaseModel
{
    var systolic:Double // systolic should be greater than diastolic
    var diastolic:Double
    private var strDiastolic = ""
    var stringValueSystolic:String
    {
        get
        {
            return stringValue
        }
        set (newVal)
        {
            stringValue = newVal
    //        systolic = (newVal as NSString!).doubleValue
        }
    }

    var stringValueDiastolic:String
    {
        get
        {
            return strDiastolic
        }
        set (newVal)
        {
            strDiastolic = newVal
            diastolic = (newVal as NSString!).doubleValue
        }
    }
    
    override init()
    {
        systolic = 0.0
        diastolic = 0.0
    }
    
    
    override func setCorrespondentDoubleValue(valueString: String) {
        systolic = (valueString as NSString!).doubleValue
    }
    
    override func FHIRResource() -> Resource? {
        let code = FHIRCode("O/E - blood pressure reading", codeId: Constant.CODE_BLOOD_PRESSURE)
        let observation = Observation(code:code  , status: "final")
        observation.comments = associatedText
        observation.effectiveDateTime = FHIRDate(super.date)
        observation.component = [ObservationComponent]()
        // systolic component
        observation.component?.append(FHIRComponent(FHIRCode("Systolic blood pressure", codeId: "114311000006111"), quantity: FHIRQuantity(stringValueSystolic, doubleQuantity: systolic, unit: "mmHg")))
        
        // diastolic component
        observation.component?.append(FHIRComponent(FHIRCode("Diastolic blood pressure", codeId: "619931000006119"), quantity: FHIRQuantity(strDiastolic, doubleQuantity: diastolic, unit: "mmHg")))
        
        return observation
    }
}