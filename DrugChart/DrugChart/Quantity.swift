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
    
    func asJSONString() ->String
    {
        var json:[String] = [String]()
        json.append(FHIRHelper.formatJSONSingleKey("valueQuantity"))
        json.append("{")
        json.append(FHIRHelper.formatJSONSingleKey("extension"))
        json.append("[")
        json.append("{")
        json.append(FHIRHelper.formatJSONKeyValue("url", value: "http://openapi.e-mis.com/fhir/extensions/string-value"))
        json.append(",")
        json.append(FHIRHelper.formatJSONKeyValue("valueString", value: self.stringValue))
        json.append("}")
        json.append("]")
        json.append(",")
        json.append(FHIRHelper.formatJSONKeyValue("value", value: self.stringValue))
        json.append(",")
        json.append(FHIRHelper.formatJSONKeyValue("unit", value: self.unit!))
        json.append("}")
        return json.joinWithSeparator(FHIRHelper.JSON_SEPARATOR)
    }
}