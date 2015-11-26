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
    }
    
    

}
