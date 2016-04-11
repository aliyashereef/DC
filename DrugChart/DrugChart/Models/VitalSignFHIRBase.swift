//
//  VitalSignFHIRBase.swift
//  DrugChart
//
//  Created by Noureen on 16/03/2016.
//
//

import Foundation
import FHIR

class VitalSignFHIRBase
{
    var guid:String = ""
    //This function only supports one code in the array.
    func FHIRCode(text:String , codeId:String ) -> CodeableConcept
    {
        let code = CodeableConcept(json: nil)
        if(!text.isEmpty)
        {
            code.text = text
        }
        let coding = Coding(json: nil)
        coding.system = NSURL(string: "http://www.e-mis.com/ClinicalCode")
        coding.code = codeId
        code.coding = [Coding]()
        code.coding?.append(coding)
        return code
    }
    
    func FHIRDate(localDate:NSDate) -> DateTime
    {
        return DateTime(string: localDate.getFHIRDateandTime())!
    }
    
    func FHIRQuantity (stringQuantity:String, unit:String) ->Quantity
    {
        let valueQuantity = Quantity(json: nil)
        valueQuantity.value = NSDecimalNumber(double: Double(stringQuantity)!)
        valueQuantity.unit = unit
        let quantityExtension = Extension(url: NSURL(string:"http://openapi.e-mis.com/fhir/extensions/string-value")!)
        quantityExtension.valueString = stringQuantity
        valueQuantity.extension_fhir = [Extension]()
        valueQuantity.extension_fhir?.append(quantityExtension)
        return valueQuantity
    }
    
    func FHIRComponent(code:CodeableConcept , quantity:Quantity) -> ObservationComponent
    {
        let component = ObservationComponent(code: code)
        component.valueQuantity = quantity
        return component
    }
    
    func FHIRResource(code:CodeableConcept , associatedText:String , effectiveDateTime:NSDate) ->Resource?
    {
        let observation = Observation(code:code  , status: "final")
        observation.comments = associatedText
        includeIdentifier(observation)
        observation.effectiveDateTime = FHIRDate(effectiveDateTime)
        return observation
    }
    
    func includeIdentifier(obs:Observation)
    {
        if(!guid.isEmpty)
        {
            obs.identifier = [Identifier]()
            let id  = Identifier(json: nil)
            id.system = NSURL(fileURLWithPath: "http://openapi.e-mis.com/fhir/guid-identifier")
            id.value = guid
            obs.identifier?.append(id)
        }
    }
    
    func FHIRResource(code:CodeableConcept , associatedText:String , effectiveDateTime:NSDate , quantity:Quantity) ->Resource?
    {
        let observation = Observation(code:code  , status: "final")
        observation.comments = associatedText
        includeIdentifier(observation)
        observation.effectiveDateTime = FHIRDate(effectiveDateTime)
        observation.valueQuantity = quantity
        //observation.valueQuantity = FHIRQuantity(stringValue, doubleQuantity: value,unit: "degrees C")
        return observation
    }
}