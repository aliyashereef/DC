//
//  DCSchedulingPickerCell.swift
//  DrugChart
//
//  Created by Jilu mary Joy on 11/13/15.
//
//

import UIKit

typealias SelectedPickerContent = NSString? -> Void

class DCSchedulingPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    var pickerType : PickerType?
    var contentArray : NSMutableArray?
    var pickerCompletion: SelectedPickerContent = { value in }
        
    func configurePickerCellForPickerType(type : PickerType) {
        
        pickerType = type
        if (pickerType! == eSchedulingFrequency) {
            contentArray = [DAILY, WEEKLY, MONTHLY, YEARLY]
        } else if (pickerType! == eDailyCount) {
            contentArray = NSMutableArray()
            for number : NSInteger in 1...7 {
                [contentArray?.addObject(number)]
            }
        } else if (pickerType! == eWeeklyCount) {
            contentArray = NSMutableArray()
            for number : NSInteger in 1...5 {
                [contentArray?.addObject(number)]
            }
        } else if (pickerType! == eMonthlyCount) {
            contentArray = NSMutableArray()
            for number : NSInteger in 1...12 {
                [contentArray?.addObject(number)]
            }
        }
        pickerView.reloadAllComponents()
    }
    
    // MARK: Picker Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return  pickerType! == eSchedulingFrequency ? 1 : 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return (component == 0) ? (contentArray?.count)! : 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var displayString : String = EMPTY_STRING
        if (pickerType! == eSchedulingFrequency) {
            displayString = contentArray?.objectAtIndex(row) as! String
        } else /*if (pickerType! == eDailyCount) */{
            if (component == 0) {
                let valueToDisplay = String((contentArray?.objectAtIndex(row))!)
                displayString = String(valueToDisplay)
            } else {
                if (pickerType! == eDailyCount) {
                    displayString = "days"
                } else if (pickerType! == eWeeklyCount) {
                    displayString = "weeks"
                } else {
                    displayString = "months"
                }
            }
        }
        return displayString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (component == 0) {
            var selectedValue : String = EMPTY_STRING
            if (pickerType! == eSchedulingFrequency) {
               // if (row == 0) { // Selection allowed for daily for this release
                    selectedValue = (contentArray?.objectAtIndex(row) as? String)!
                    pickerCompletion(selectedValue)
               // }
            } else {
                let valueToDisplay = String((contentArray?.objectAtIndex(row))!)
                selectedValue = String(valueToDisplay)
                pickerCompletion(selectedValue)
            }
        }
    }
}
