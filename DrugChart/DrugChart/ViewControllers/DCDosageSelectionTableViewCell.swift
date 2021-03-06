//
//  DCDosageSelectionTableViewCell.swift
//  DrugChart
//
//  Created by Shaheer on 10/12/15.
//
//

import UIKit

class DCDosageSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var dosageMenuLabel: UILabel!
    @IBOutlet weak var dosageDetailLabel: UILabel!
    @IBOutlet weak var dosageDetailValueLabel: UILabel!
    @IBOutlet weak var requiredDailyDoseTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textFieldStringDidChange(sender: AnyObject) {
        
        requiredDailyDoseTextField.textColor = UIColor.blackColor()
        if self.validateRequireDailyDoseValue(requiredDailyDoseTextField.text!) {
            requiredDailyDoseTextField.textColor = UIColor.blackColor()
        } else {
            requiredDailyDoseTextField.textColor = UIColor.redColor()
        }
    }
    
    func validateRequireDailyDoseValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        if isNumeric && NSString(string: value).floatValue != 0 && value.characters.count <= 5 && NSString(string: value).floatValue < maximumValueOfDose{
            return true
        } else {
            return false
        }
    }

    func configureCell(cellTitle:String? ,selectedValue:String? ) {
        
        dosageDetailLabel.text = cellTitle
        dosageDetailValueLabel.text = selectedValue
        dosageDetailLabel.textColor = UIColor.blackColor()
        accessoryType = .DisclosureIndicator
    }
    
    func configureCellForErrorCondition(cellTitle:String? ,selectedValue:String? ) {
        
        dosageDetailLabel.text = cellTitle
        dosageDetailValueLabel.text = selectedValue
        dosageDetailLabel.textColor = UIColor.redColor()
        accessoryType = .DisclosureIndicator
    }
}
