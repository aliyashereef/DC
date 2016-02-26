//
//  PickerCell.swift
//  vitalsigns
//
//  Created by Noureen on 16/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class PickerCell: UITableViewCell , UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    var dataSource :[String]!
    var pickerView:UIPickerView = UIPickerView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textFieldEditing(sender: UITextField) {
        //pickerView.dataSource = ["noureen","samina"]
        pickerView.delegate=self
        sender.inputView = pickerView
        
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

    }
    
    func donePicker()
    {
        valueTextField.text = dataSource[pickerView.selectedRowInComponent(0)]
        valueTextField.resignFirstResponder()
    }
    func cancelPicker() {
        valueTextField.resignFirstResponder()
    }
    
    func timePickerValueChanged(sender:UIDatePicker) {
        
        // valueTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    func configureCell(title:String , valuePlaceHolderText:String,pickerOptions:[String] )
    {
        titleLabel.text = title;
        valueTextField.placeholder = valuePlaceHolderText
        dataSource = pickerOptions
    }
    
    
    //MARK: Picker View components
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueTextField.text = dataSource[row]
    }
    
}
