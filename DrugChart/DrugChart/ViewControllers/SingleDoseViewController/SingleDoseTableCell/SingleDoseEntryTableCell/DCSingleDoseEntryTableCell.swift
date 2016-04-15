//
//  DCSingleDoseEntryTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 2/25/16.
//
//

import UIKit

protocol SingleDoseEntryCellDelegate {
    
    func singleDoseValueChanged(dose : String?)
}

class DCSingleDoseEntryTableCell: UITableViewCell , UITextFieldDelegate {

    @IBOutlet weak var singleDoseTextfield: UITextField!
    
    var singleDoseDelegate : SingleDoseEntryCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func singleDoseTextfieldValueChanged(sender: AnyObject) {
        
        singleDoseTextfield.textColor = UIColor.blackColor()
        if DCDosageHelper.validateRequireDailyDoseValue(singleDoseTextfield.text!) {
            singleDoseTextfield.textColor = UIColor.blackColor()
        } else {
            singleDoseTextfield.textColor = UIColor.redColor()
        }
        if let delegate = self.singleDoseDelegate {
            delegate.singleDoseValueChanged(singleDoseTextfield.text!)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Create an `NSCharacterSet` set which includes everything *but* the digits
        let inverseSet = NSCharacterSet(charactersInString:INTEGER_SET_STRING).invertedSet
        
        // At every character in this "inverseSet" contained in the string,
        // split the string up into components which exclude the characters
        // in this inverse set
        let components = string.componentsSeparatedByCharactersInSet(inverseSet)
        
        // Rejoin these components
        let filtered = components.joinWithSeparator(EMPTY_STRING)
        
        // If the original string is equal to the filtered string, i.e. if no
        // inverse characters were present to be eliminated, the input is valid
        // and the statement returns true; else it returns false
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        if (NSString(string: newString).floatValue > maximumValueOfDose) {
            return false
        }
        let arrayOfString: [AnyObject] = newString.componentsSeparatedByString(".")
        if arrayOfString.count > 2 {
            return false
        }
        return string == filtered
    }
}
