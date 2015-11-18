//
//  DoubleCell.swift
//  vitalsigns
//
//  Created by Noureen on 01/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class DoubleCell: UITableViewCell ,UITextFieldDelegate {

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var value: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        value.delegate=self
        // Initialization code
        value.textAlignment = NSTextAlignment.Right
//        addDoneButtonToKeyboard()
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let touch = touches.first as UITouch! {
//            value.resignFirstResponder()
//        }
//        super.touchesBegan(touches , withEvent:event)
//    }
//    
    
    func  getValue() ->Double
    {
        return (value.text as NSString!).doubleValue
    }
    
    func isValueEntered() -> Bool
    {
        if (value.text == nil || value.text!.isEmpty == true)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func configureCell(title:String , valuePlaceHolderText:String , selectedValue:Double! )
    {
        titleText.text = title;
        value.placeholder = valuePlaceHolderText
        if selectedValue != nil
        {
            value.text = String(selectedValue)
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        value.resignFirstResponder()
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
        
        
//        switch textField {
//            
//            // Allow only upper- and lower-case vowels in this field,
//            // and limit its contents to a maximum of 6 characters.
//        case vowelsOnlyTextField:
//            return prospectiveText.containsOnlyCharactersIn("aeiouAEIOU") &&
//                prospectiveText.characters.count <= 6
//            
//            // Allow any characters EXCEPT upper- and lower-case vowels in this field,
//            // and limit its contents to a maximum of 8 characters.
//        case noVowelsTextField:
//            return prospectiveText.doesNotContainCharactersIn("aeiouAEIOU") &&
//                prospectiveText.characters.count <= 8
//            
//            // Allow only digits in this field,
//            // and limit its contents to a maximum of 3 characters.
//        case digitsOnlyTextField:
//            return prospectiveText.containsOnlyCharactersIn("0123456789") &&
//                prospectiveText.characters.count <= 3
//            
//            // Allow only values that evaluate to proper numeric values in this field,
//            // and limit its contents to a maximum of 7 characters.
//        case numericOnlyTextField:
//            return prospectiveText.isNumeric() &&
//                prospectiveText.characters.count <= 7
//            
//            // In this field, allow only values that evalulate to proper numeric values and
//            // do not contain the "-" and "e" characters, nor the decimal separator character
//            // for the current locale. Limit its contents to a maximum of 5 characters.
//        case positiveIntegersOnlyTextField:
//            let decimalSeparator = NSLocale.currentLocale().objectForKey(NSLocaleDecimalSeparator) as! String
//            return prospectiveText.isNumeric() &&
//                prospectiveText.doesNotContainCharactersIn("-e" + decimalSeparator) &&
//                prospectiveText.characters.count <= 5
//            
//            // Do not put constraints on any other text field in this view
//            // that uses this class as its delegate.
//        default:
//            return true
//        }
    }
//
//    func addDoneButtonToKeyboard() {
//        var doneButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "hideKeyboard")
//        
//        var space:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
//        
//        var items = [AnyObject]()
//        items.append(space)
//        items.append(doneButton)
//        var toolbar = UIToolbar.new()
//        
//        toolbar.frame.size.height = 35
//        
//        toolbar.items = items
//        
//        value.inputAccessoryView = toolbar
//    }
    
//    func hideKeyboard() {
//        value.resignFirstResponder()
//    }

}
