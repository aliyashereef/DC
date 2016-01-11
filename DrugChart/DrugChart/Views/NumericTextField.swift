//
//  NumericTextField.swift
//  DrugChart
//
//  Created by Noureen on 24/12/2015.
//
//

import UIKit

class NumericTextField: UITextField ,UITextFieldDelegate{

    var buttonActionDelegate:ButtonAction?
    var minimumObservationRow:Int!
    var maximumObservationRow:Int!
    var disableNavigation:Bool!

    func initialize(disableNavigation:Bool)
    {
        self.delegate = self
        self.disableNavigation = disableNavigation
        addDoneButtonOnKeyboard()
    }
    
    func isValueEntered() -> Bool
    {
        if (self.text == nil || self.text!.isEmpty == true)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
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
        
        if(disableNavigation == true)
        {
            previousButton.enabled = false
            nextButton.enabled = false
        }
        else
        {
            if(disableNavigation == true || self.tag == Constant.MINIMUM_OBSERVATION_ROW )
            {
                previousButton.enabled = false
            }
            else if(disableNavigation == true || self.tag == Constant.MAXIMUM_OBSERVATION_ROW)
            {
                nextButton.enabled = false
            }
        }
        toolbar.setItems([previousButton, fixedSpaceButton, nextButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        self.inputAccessoryView = toolbar
    }
    
    func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    func nextButtonAction()
    {
        buttonActionDelegate?.nextButtonAction()
    }
    func previousButtonAction()
    {
        buttonActionDelegate?.previousButtonAction()
    }
    //Mark: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String)
        -> Bool
    {
        // We ignore any change that doesn't add characters to the text field.
        // These changes are things like character deletions and cuts, as well
        // as moving the insertion point.
        //
        // We still return true to allow the change to take place.
        if string.characters.count == 0 {
            return true
        }
        
        // Check to see if the text field's contents still fit the constraints
        // with the new content added to it.
        // If the contents still fit the constraints, allow the change
        // by returning true; otherwise disallow the change by returning false.
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        return prospectiveText.containsOnlyCharactersIn("0123456789.") &&
            prospectiveText.characters.count <= 5
    }
    
}
