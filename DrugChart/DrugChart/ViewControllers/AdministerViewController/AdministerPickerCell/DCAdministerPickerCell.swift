//
//  DCAdministerPickerCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/29/15.
//
//

import UIKit

protocol AdministerPickerCellDelegate {
    
    func newDateValueSelected(newDate : NSDate)
}

class DCAdministerPickerCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate : AdministerPickerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func datePickerValueChanged(sender: AnyObject) {
        
        // date picker value changed
        if (delegate != nil){
            delegate!.newDateValueSelected(datePicker.date)
        }
    }
}
