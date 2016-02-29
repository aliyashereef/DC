//
//  DCAddConditionDetailTableViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

class DCAddConditionDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var newDoseTextField: UITextField!

    @IBOutlet weak var valueForDoseLabel: UILabel!
    @IBOutlet weak var newDoseLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func newDoseTextChanged(sender: AnyObject) {

        newDoseTextField.textColor = UIColor.blackColor()
        if self.validateNewDosageValue(newDoseTextField.text!) {
            newDoseTextField.textColor = UIColor.blackColor()
        } else {
            newDoseTextField.textColor = UIColor.redColor()
        }
    }
    
    func validateNewDosageValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        return isNumeric && (NSString(string: value).floatValue < 10000)
    }
}
