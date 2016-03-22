//
//  Bundle.swift
//  DrugChart
//
//  Created by Noureen on 14/03/2016.
//
//

import Foundation
import FHIR

extension Bundle
{
    func asJSONString() ->String
    {
        var json:[String] = [String]()
        json.append("{")
        json.append(FHIRHelper.formatJSONKeyValue("resourceType", value: "Bundle"))
        json.append(",")
        json.append(FHIRHelper.formatJSONKeyValue("type", value: "transaction"))
        json.append(",")
        json.append(FHIRHelper.formatJSONSingleKey("entry"))
        if(self.entry?.count>0)
        {
            json.append("[")
            var appendComma = false
            for entry in self.entry!
            {
                if(appendComma)
                {
                    json.append(",")
                }
                json.append(entry.asJSONString())
                appendComma = true
            }
            json.append("]")
        }
        json.append("}")
        return json.joinWithSeparator(FHIRHelper.JSON_SEPARATOR)
    }
    
    
}