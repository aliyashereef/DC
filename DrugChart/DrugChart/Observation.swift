//
//  Observation.swift
//  DrugChart
//
//  Created by Noureen on 14/03/2016.
//
//

import Foundation
import FHIR

extension Observation
{

    func asJSONString() -> String
    {
        var json:[String] = [String]()
        json.append(FHIRHelper.formatJSONKeyValue("resourceType", value: "Observation"))
        json.append(",")
        json.append(FHIRHelper.formatJSONKeyValue("effectiveDateTime", value: self.effectiveDateTime!.nsDate.getFHIRDateandTime()))
        json.append(",")
        json.append(FHIRHelper.formatJSONKeyValue("status", value: "final"))
        json.append(",")
        json.append(FHIRHelper.formatJSONKeyValue("comments", value: self.comments!))
        json.append(",")
        json.append((self.code?.asJSONString())!)
        if(self.valueQuantity != nil)
        {
            json.append(",")
            json.append((self.valueQuantity?.asJSONString())!)
        }
        if(self.identifier?.count>0)
        {
            json.append(",")
            json.append(self.identifier![0].asJSONString())
        }
        if(self.component?.count>0)
        {
            var appendComma = false
            json.append(",")
            json.append(FHIRHelper.formatJSONSingleKey("component"))
            json.append("[")
            for component in self.component!
            {
                if(appendComma)
                {
                    json.append(",")
                }
                json.append(component.asJSONString())
                appendComma = true
            }
            json.append("]")
        }
        return json.joinWithSeparator(FHIRHelper.JSON_SEPARATOR)
    }

}