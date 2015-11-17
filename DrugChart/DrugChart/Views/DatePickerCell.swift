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
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        // configure the toolbar as well
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPicker")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        sender.inputAccessoryView = toolBar

        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    func donePicker()
    {
        formatDate()
        dateTextField.resignFirstResponder()
    }
    func cancelPicker() {
        dateTextField.resignFirstResponder()
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        
//        let dateFormatter = NSDateFormatter()
//        
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        
//        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
//        
//        date = sender.date
//        dateTextField.text = dateFormatter.stringFromDate(sender.date)
//        
    }
    func formatDate()
    {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        date = datePickerView.date
        dateTextField.text = dateFormatter.stringFromDate(datePickerView.date)
        
    }

}
