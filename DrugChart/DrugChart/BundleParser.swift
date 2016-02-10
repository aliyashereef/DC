//
//  BundleParser.swift
//  DrugChart
//
//  Created by Noureen on 05/02/2016.
//
//

import Foundation

class BundleParser : FhirParser
{
    func getVitalSignsObservations(apiURL:String) -> [VitalSignObservation]!
    {
        super.connectServer(apiURL){(responseObject:String? , error:NSError? ) in
            if(error != nil)
            {
                print(error?.localizedDescription)
            }
            else
            {
                print("got the response")
                print(responseObject)
            }
        }
        return nil
    }
    
    
//    override func connectServer(apiURL: String) -> String! {
//        let jsonResponse = super.connectServer(apiURL)
//        print(jsonResponse)
//        return jsonResponse
//    }
}