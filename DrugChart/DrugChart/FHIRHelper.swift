//
//  FHIRHelper.swift
//  DrugChart
//
//  Created by Noureen on 14/03/2016.
//
//

import Foundation
class FHIRHelper
{
    static let JSON_SEPARATOR = " "
    static func formatJSONKeyValue(element:String, value:String) ->String
    {
        return String(format: "\"%@\" : \"%@\"", element , value)
    }
    static func formatJSONSingleKey(element:String) ->String
    {
        return String(format: "\"%@\" : ", element)
    }

}