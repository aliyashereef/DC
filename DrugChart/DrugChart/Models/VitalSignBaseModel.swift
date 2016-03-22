//
//  VitalSignBaseModel.swift
//  DrugChart
//
//  Created by Noureen on 17/02/2016.
//
//

import Foundation
import FHIR

class VitalSignBaseModel : VitalSignFHIRBase
{
    var date:NSDate = NSDate()
    private var strValue = ""
    var associatedText = ""
    var stringValue:String
    {
        set (newVal)
        {
            strValue = newVal
            setCorrespondentDoubleValue(newVal)
        }
        get
        {
            return strValue
        }
    }
    
    func setCorrespondentDoubleValue(valueString:String)
    {
        //Every child class must have to override this class.
    }
    
    func FHIRResource() ->Resource?
    {
        return nil
    }
    
    func isValueEntered() -> Bool
    {
        return !strValue.isEmpty
    }
    
    
    func delete()
    {
        stringValue = ""
    }
}