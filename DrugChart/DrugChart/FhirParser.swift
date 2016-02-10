//
//  FhirParser.swift
//  DrugChart
//
//  Created by Noureen on 05/02/2016.
//
//

import Foundation
import FHIR
import AFNetworking

typealias ServiceResponse = (String?, NSError?) -> Void
class FhirParser
{
    
    func connectServer(apiURL:String,onCompletion:ServiceResponse)->Void
    {
        let manager = DCHTTPRequestOperationManager.sharedVitalSignManager()
        
        manager.GET(apiURL ,
            parameters: nil,
            success: { (operation,responseObject) ->Void in
                //let responseDict = responseObject as! NSDictionary
                onCompletion(responseObject.description, nil)
            },
            failure: { (operation , error) in
                //print("Error: " + error.localizedDescription)
                onCompletion(nil,error)
        })
    }
    
    func parseJSON(responseObject:String?)
    {
        print(responseObject) // every class must have to implement it own method
    }
}