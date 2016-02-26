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
import CocoaLumberjack

typealias ServiceResponse = (FHIRJSON?, NSError?) -> Void
class FhirParser
{
    
    func connectServer(apiURL:String,onCompletion:ServiceResponse)->Void
    {
        let manager = DCHTTPRequestOperationManager.sharedVitalSignManager()
        DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) API call url:\(apiURL)")
        manager.GET(apiURL ,
            parameters: nil,
            success: { (operation,responseObject) ->Void in
                DDLogDebug("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) Get JSON back:\(responseObject.description)")
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(responseObject as! NSData, options:NSJSONReadingOptions.MutableContainers) as? FHIRJSON
                    onCompletion(json, nil)
                }
                catch
                {
                    DDLogError("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) Get Error\(error)")
                }
            },
            failure: { (operation , error) in
                DDLogError("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) Get Error:\(error.localizedDescription)")
                onCompletion(nil,error)
        })
        
    }
    
    // This method converts string to FHIR JSON
    func getFHIRJSON(json:String) -> FHIRJSON?
    {
        do
        {
            let data = json.dataUsingEncoding(NSUTF8StringEncoding)
            let fhirJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? FHIRJSON
            return fhirJSON
        }
        catch
        {
            DDLogError("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) Get Error\(error)")
        }
        
        return nil
    }
}