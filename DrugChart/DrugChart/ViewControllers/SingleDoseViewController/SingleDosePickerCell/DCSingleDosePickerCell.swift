//
//  DCSingleDosePickerCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy  on 2/18/16.
//
//

import UIKit

typealias PickerSelectionCompletion = NSString? -> Void

class DCSingleDosePickerCell: UITableViewCell {
    
    @IBOutlet weak var datePickerView: UIDatePicker!
    var pickerCompletion: PickerSelectionCompletion?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        datePickerView.timeZone = NSTimeZone(abbreviation: GMT)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Action Methods
    
    @IBAction func singleDosedatePickerValueChanged(sender: AnyObject) {
        
        let dateString = DCDateUtility.dateStringFromDate(datePickerView.date, inFormat: START_DATE_FORMAT)
        pickerCompletion!(dateString)
    }

}
