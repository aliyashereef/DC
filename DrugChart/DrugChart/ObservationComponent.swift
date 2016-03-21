//
//  ObservationComponent.swift
//  DrugChart
//
//  Created by Noureen on 14/03/2016.
//
//

import Foundation
import FHIR

extension ObservationComponent
{
    func asJSONString() ->String
    {
        var json:[String] = [String]()
        json.append("{")
        json.append((self.code?.asJSONString())!)
        json.append(",")
        json.append((self.valueQuantity?.asJSONString())!)
       json.append("}")
        return json.joinWithSeparator(FHIRHelper.JSON_SEPARATOR)
    }

}