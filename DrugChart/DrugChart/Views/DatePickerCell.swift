//
//  DatePickerCell.swift
//  vitalsigns
//
//  Created by Noureen on 07/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {

   // private var date :NSDate = NSDate()
    @IBOutlet weak var dateTextField: UITextField!
    
    // Class variable workaround.
    struct Stored {
        static var dateFormatter = NSDateFormatter()
    }
    
    var datePickerView: UIDatePicker = UIDatePicker()
    /// The selected date, set to current date/time on initialization.
     var date:NSDate = NSDate() {
        didSet {
            datePickerView.date = date
            DatePickerCellInline.Stored.dateFormatter.dateStyle = dateStyle
            DatePickerCellInline.Stored.dateFormatter.timeStyle = timeStyle
            dateTextField.text = DatePickerCellInline.Stored.dateFormatter.stringFromDate(date)
        }
    }
    /// The timestyle.
     var timeStyle = NSDateFormatterStyle.NoStyle
    /// The datestyle.
     var dateStyle = NSDateFormatterStyle.MediumStyle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePickerView.datePickerMode = UIDatePickerMode.Date
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func configureCell( valuePlaceHolderText:String )
//    {
//        titleText.text = title;
//        value.placeholder = valuePlaceHolderText
//    }
//    
    @IBAction func textFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        date = sender.date
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }

}
