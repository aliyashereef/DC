//
//  AddNewValueTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 02/02/16.
//
//

import UIKit

class DCAddNewValueTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var newValueTextField: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var unitValueLabel: UILabel!
    @IBOutlet weak var unitValueTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newValueTextField?.delegate = self
        // Initialization code
//        newValueTextField.becomeFirstResponder()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Create an `NSCharacterSet` set which includes everything *but* the digits
        let inverseSet = NSCharacterSet(charactersInString:INTEGER_SET_STRING).invertedSet
        
        // At every character in this "inverseSet" contained in the string,
        // split the string up into components which exclude the characters
        // in this inverse set
        let components = string.componentsSeparatedByCharactersInSet(inverseSet)
        
        // Rejoin these components
        let filtered = components.joinWithSeparator(EMPTY_STRING)  // use join(EMPTY_STRING, components) if you are using Swift 1.2
        
        // If the original string is equal to the filtered string, i.e. if no
        // inverse characters were present to be eliminated, the input is valid
        // and the statement returns true; else it returns false
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        let arrayOfString: [AnyObject] = newString.componentsSeparatedByString(".")
        if arrayOfString.count > 2 {
            return false
        }
        return string == filtered
    }

}
