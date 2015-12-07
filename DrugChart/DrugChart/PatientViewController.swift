//
//  BasePatient.swift
//  DrugChart
//
//  Created by Noureen on 01/12/2015.
//
//

import Foundation

class PatientViewController:DCBaseViewController,Patient
{
    private var patientObject = DCPatient.init()
    
    var patient:DCPatient
    {
        get
        {
            return self.patientObject
        }
        set
        {
            self.patientObject = newValue
        }
    }

}