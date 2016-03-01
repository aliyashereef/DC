//
//  VitalSignBaseModel.swift
//  DrugChart
//
//  Created by Noureen on 17/02/2016.
//
//

import Foundation

class VitalSignBaseModel
{
    var date:NSDate = NSDate()
    private var strValue = ""
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
}