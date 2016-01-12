//
//  DCAddNewDoseAndTimeTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

class DCAddNewDoseAndTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var newDosageTextField: UITextField!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textFieldStringDidChange(sender: AnyObject) {
        
        newDosageTextField.textColor = UIColor.blackColor()
        if self.validateRequireDailyDoseValue(newDosageTextField.text!) {
            newDosageTextField.textColor = UIColor.blackColor()
        } else {
            newDosageTextField.textColor = UIColor.redColor()
        }
    }
    
    func validateRequireDailyDoseValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        return isNumeric
    }


}
