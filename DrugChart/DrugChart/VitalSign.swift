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
            if(error == nil)
            {
                //let bundle = Bundle.init(json: json)
                let listObservations = [VitalSignObservation]()
                onSuccess(observationList: listObservations)
            }
    }
    }
}