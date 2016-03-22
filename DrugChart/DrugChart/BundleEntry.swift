//
//  BundleEntry.swift
//  DrugChart
//
//  Created by Noureen on 14/03/2016.
//
//

import Foundation
import FHIR

extension BundleEntry
{
    func asJSONString() ->String
    {
        var json:[String] = [String]()
        json.append("{")
        json.append(FHIRHelper.formatJSONSingleKey("resource"))
        json.append("{")
        let observation = self.resource as? Observation
        json.append((observation?.asJSONString())!)
        json.append("}")
        json.append("}")
        return json.joinWithSeparator(FHIRHelper.JSON_SEPARATOR)
    }
}