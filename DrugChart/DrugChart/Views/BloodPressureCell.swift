//
//  BloodPressureCell.swift
//  vitalsigns
//
//  Created by Noureen on 06/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

class BloodPressureCell: UITableViewCell ,UITextFieldDelegate{

    @IBOutlet weak var systolicValue: UITextField!
    @IBOutlet weak var diastolicValue: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        systolicValue.delegate = self
        diastolicValue.delegate = self
    }
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func isValueEntered() -> Bool
    {
       // if  (systolicValue.text != nil && systolicValue.text?.isEmpty==false)
        if (systolicValue.text == nil || systolicValue.text!.isEmpty == true)
            
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func  getSystolicValue() ->Double
    {
        return (systolicValue.text as NSString!).doubleValue
    }
    
    func  getDiastolicValue() ->Double
    {
        return (diastolicValue.text as NSString!).doubleValue
    }
}
