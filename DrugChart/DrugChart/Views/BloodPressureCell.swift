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
    var delegate:CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        systolicValue.delegate = self
        diastolicValue.delegate = self
        addDoneButtonOnKeyboard()
    }
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func isValueEntered() -> Bool
    {
        if (systolicValue.text == nil || systolicValue.text!.isEmpty == true)
            
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        systolicValue.resignFirstResponder()
        diastolicValue.resignFirstResponder()
        return true
    }
    
    
    func  getSystolicValue() ->Double
    {
        return (systolicValue.text as NSString!).doubleValue
    }
    
    func  getDiastolicValue() ->Double
    {
        return (diastolicValue.text as NSString!).doubleValue
    }
    //Mark: Done button on keyboard
    func addDoneButtonOnKeyboard()
    {
        let toolbar = UIToolbar()
        toolbar.barStyle = .Default
        toolbar.translucent = true
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneButtonAction")
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedSpaceButton.width = 20
        
        let previousButton  = UIBarButtonItem(image :UIImage(named:"previous"), style: .Plain, target: self, action: "previousButtonAction")
        
        let nextButton  = UIBarButtonItem(image :UIImage(named:"next"), style: .Plain, target: self, action: "nextButtonAction")
        
        toolbar.setItems([previousButton, fixedSpaceButton, nextButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        self.systolicValue.inputAccessoryView = toolbar
        self.diastolicValue.inputAccessoryView = toolbar
    }
    func doneButtonAction()
    {
        self.systolicValue.resignFirstResponder()
        self.diastolicValue.resignFirstResponder()
    }
    
    func nextButtonAction()
    {
        if(self.systolicValue.isFirstResponder())
        {
            self.diastolicValue.becomeFirstResponder()
        }
        else if(self.diastolicValue.isFirstResponder())
        {
            delegate?.moveNext(self.tag)
        }
    }
    func previousButtonAction()
    {
        delegate?.movePrevious(self.tag)
    }
    
    func getFocus()
    {
        self.systolicValue.becomeFirstResponder()
    }

}
