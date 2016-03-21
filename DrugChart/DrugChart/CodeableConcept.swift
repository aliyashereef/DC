//
//  CodeableConcept.swift
//  DrugChart
//
//  Created by Noureen on 14/03/2016.
//
//

import Foundation
import FHIR
extension CodeableConcept
{
    func asJSONString() ->String
    {
        let codingTemplate = "[  { \"system\": \"%@\" ,  \"code\": \"%@\" }  ]"
        var json:[String] = [String]()
        json.append(FHIRHelper.formatJSONSingleKey("code"))
        json.append("{")
        json.append(FHIRHelper.formatJSONSingleKey("coding"))
        json.append(String(format:codingTemplate , self.coding![0].system! , self.coding![0].code!))
        json.append("}")
        return json.joinWithSeparator(FHIRHelper.JSON_SEPARATOR)
    }
}