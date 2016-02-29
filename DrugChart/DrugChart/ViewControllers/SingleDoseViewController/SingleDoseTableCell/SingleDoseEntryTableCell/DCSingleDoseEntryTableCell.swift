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

class DCSingleDoseEntryTableCell: UITableViewCell {

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

}
