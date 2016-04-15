
//
//  DCDosageDetailTableViewCell.swift
//  DrugChart
//
//  Created by Shaheer on 11/12/15.
//
//

import UIKit

class DCDosageDetailTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var dosageDetailDisplayCell: UILabel!
    @IBOutlet weak var dosageDetailCellLabel: UILabel!
    @IBOutlet weak var addNewDosageTextField: UITextField!
    @IBOutlet weak var dosageDetailValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func newDoseTextChanged(sender: AnyObject) {
        
        addNewDosageTextField.textColor = UIColor.blackColor()
        if self.validateNewDosageValue(addNewDosageTextField.text!) {
            addNewDosageTextField.textColor = UIColor.blackColor()
        } else {
            addNewDosageTextField.textColor = UIColor.redColor()
        }
    }
    
    func validateNewDosageValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        return isNumeric && (NSString(string: value).floatValue <= maximumValueOfDose)
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
