//
//  VitalSignBaseModel.swift
//  DrugChart
//
//  Created by Noureen on 17/02/2016.
//
//

import Foundation
import FHIR

class VitalSignBaseModel
{
    var date:NSDate = NSDate()
    private var strValue = ""
    var associatedText = ""
    var stringValue:String
    {
        set (newVal)
        {
            strValue = newVal
            setCorrespondentDoubleValue(newVal)
        }
        get
        {
            return strValue
        }
    }
    
    func setCorrespondentDoubleValue(valueString:String)
    {
        //Every child class must have to override this class.
    }
    
    func FHIRResource() ->Resource?
    {
        return nil
    }
    
    func isValueEntered() -> Bool
    {
        return !strValue.isEmpty
    }
    
    //This function only supports one code in the array.
    func FHIRCode(text:String , codeId:String ) -> CodeableConcept
    {
        let code = CodeableConcept(json: nil)
        code.text = text
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
    
    func FHIRQuantity (stringQuantity:String,doubleQuantity:Double, unit:String) ->Quantity
    {
        let valueQuantity = Quantity(json: nil)
        valueQuantity.value = NSDecimalNumber(double: doubleQuantity)
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
}