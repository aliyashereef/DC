//
//  Identifier.swift
//  DrugChart
//
//  Created by Noureen on 21/03/2016.
//
//

import Foundation
import FHIR

extension Identifier
{
    func asJSONString() ->String
    {
        let identifierTemplate = "[  { \"system\": \"%@\" ,  \"value\": \"%@\" }  ]"
        var json:[String] = [String]()
        json.append(FHIRHelper.formatJSONSingleKey("identifier"))
        json.append(String(format:identifierTemplate , "http://openapi.e-mis.com/fhir/guid-identifier" ,self.value!))
        return json.joinWithSeparator(FHIRHelper.JSON_SEPARATOR)
    }
}