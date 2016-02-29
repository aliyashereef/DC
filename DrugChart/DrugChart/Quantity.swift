//
//  Quantity.swift
//  DrugChart
//
//  Created by Noureen on 29/02/2016.
//
//

import Foundation
import FHIR

extension Quantity
{
    var stringValue:String
    {
        get
            {var stringValue : String = ""
        if(self.extension_fhir?.count > 0)
        {
            let value = self.extension_fhir![0]
            stringValue = value.valueString!
        }
        return stringValue
        }
    }
}