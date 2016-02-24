
//
//  DCDosageDetailTableViewCell.swift
//  DrugChart
//
//  Created by Shaheer on 11/12/15.
//
//

import UIKit

class DCDosageDetailTableViewCell: UITableViewCell {

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
        return isNumeric && (NSString(string: value).floatValue < 10000)
    }

}
