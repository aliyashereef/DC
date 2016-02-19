//
//  BundleParser.swift
//  DrugChart
//
//  Created by Noureen on 05/02/2016.
//
//

import Foundation
import FHIR

class VitalSignParser : FhirParser
{
   
    func getVitalSignsObservations(apiURL:String , onSuccess:(observationList:[VitalSignObservation])->Void)
    {
        super.connectServer(apiURL){(json:FHIRJSON? , error:NSError? ) in
            if(error == nil) //so there is no error and the json can be parsed now.
            {
                //let bundle = Bundle.init(json: json)
                //boc test
                if let path = NSBundle.mainBundle().pathForResource("observation", ofType: "json" ) as String!
                
                {
                    let bundle = try! Bundle.instantiateFromPath(path)
                    let obs = bundle.entry?[0].resource as! Observation
                    print(obs.valueQuantity?.value)
                    print(obs.effectiveDateTime)
                    print(bundle.entry?.count)
                }
                //
                //eoc test
                let listObservations = [VitalSignObservation]()
                onSuccess(observationList: listObservations)
            }
    }
    }
}