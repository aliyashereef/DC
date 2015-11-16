//
//  TimePickerCell.swift
//  vitalsigns
//
//  Created by Noureen on 07/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class TimePickerCell: UITableViewCell {
    
   // @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    }
    
    @IBAction func textFieldEditing(sender: UITextField) {
    let datePickerView:UIDatePicker = UIDatePicker()
    
    datePickerView.datePickerMode = UIDatePickerMode.Time
    
    sender.inputView = datePickerView
    
    datePickerView.addTarget(self, action: Selector("timePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func timePickerValueChanged(sender:UIDatePicker) {
    
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
    
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    
    timeTextField.text = dateFormatter.stringFromDate(sender.date)
    
    }
    
}

