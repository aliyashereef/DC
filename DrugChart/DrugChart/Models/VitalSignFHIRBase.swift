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
        observation.effectiveDateTime = FHIRDate(effectiveDateTime)
        return observation
    }
    
    func FHIRResource(code:CodeableConcept , associatedText:String , effectiveDateTime:NSDate , quantity:Quantity) ->Resource?
    {
        //let code = FHIRCode( "O/E - oral temperature taken",codeId: Constant.CODE_ORAL_TEMPERATURE)
        let observation = Observation(code:code  , status: "final")
        observation.comments = associatedText
        observation.effectiveDateTime = FHIRDate(effectiveDateTime)
        observation.valueQuantity = quantity
        //observation.valueQuantity = FHIRQuantity(stringValue, doubleQuantity: value,unit: "degrees C")
        return observation
    }
}