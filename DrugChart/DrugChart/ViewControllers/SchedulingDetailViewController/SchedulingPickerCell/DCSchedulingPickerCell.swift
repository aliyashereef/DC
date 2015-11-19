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
    var weekDaysArray : NSArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var previousFilledValue : NSString?
    var repeatValue : DCRepeat?
    var pickerCompletion: SelectedPickerContent = { value in }
        
    func configurePickerCellForPickerType(type : PickerType) {
        
        pickerType = type
        contentArray = NSMutableArray()
        if (pickerType! == eSchedulingFrequency) {
            contentArray = [DAILY, WEEKLY, MONTHLY, YEARLY]
            if let repeatType = repeatValue?.repeatType {
                let selectedIndex = contentArray?.indexOfObject(repeatType)
                [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
            }
        } else if (pickerType! == eDailyCount) {
            for number : NSInteger in 1...7 {
                [contentArray?.addObject(number)]
            }
            if let dailyFrequency = repeatValue?.frequency {
                if let range = dailyFrequency.rangeOfString(" ") {
                    let dailyCount = dailyFrequency.substringToIndex(range.startIndex)
                    let selectedIndex = contentArray?.indexOfObject(Int(dailyCount)!)
                    [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
                }
            }
        } else if (pickerType! == eWeeklyCount) {
            for number : NSInteger in 1...5 {
                [contentArray?.addObject(number)]
            }
            if let weeklyFrequency = repeatValue?.frequency {
                if let range = weeklyFrequency.rangeOfString(" ") {
                    let weeklyCount = weeklyFrequency.substringToIndex(range.startIndex)
                    let selectedIndex = contentArray?.indexOfObject(Int(weeklyCount)!)
                    [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
                }
            }
        } else if (pickerType! == eMonthlyCount) {
            for number : NSInteger in 1...12 {
                [contentArray?.addObject(number)]
            }
            if let monthlyFrequency = repeatValue?.frequency {
                if let range = monthlyFrequency.rangeOfString(" ") {
                    let monthlyCount = monthlyFrequency.substringToIndex(range.startIndex)
                    let selectedIndex = contentArray?.indexOfObject(Int(monthlyCount)!)
                    [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
                }
            }
        } else if (pickerType! == eMonthEachCount) {
            for number : NSInteger in 1...31 {
                [contentArray?.addObject(number)]
            }
            if let monthEach = repeatValue?.eachValue {
                if let range = monthEach.rangeOfString(" ") {
                    let monthlyCount = monthEach.substringToIndex(range.startIndex)
                    let selectedIndex = contentArray?.indexOfObject(Int(monthlyCount)!)
                    [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
                }
            }
        } else if (pickerType! == eMonthOnTheCount) {
            contentArray = [FIRST, SECOND, THIRD, FOURTH, FIFTH, LAST]
        }
        pickerView.reloadAllComponents()
    }
    
    func selectPickerViewRowForRepeatParameter(repeatParameter : NSString, forContentArray contents : NSArray) {
        //
        
    
    }
    
    // MARK: Picker Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        if (pickerType! == eSchedulingFrequency || pickerType! == eMonthEachCount) {
            return 1
        } else {
            return 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (component == 0) {
            return (contentArray?.count)!
        } else {
            return (pickerType! == eMonthOnTheCount) ? (weekDaysArray.count) : 1
        }
        
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
                } else if (pickerType! == eMonthlyCount) {
                    displayString = "months"
                } else if (pickerType! == eMonthOnTheCount) {
                    displayString = weekDaysArray.objectAtIndex(row) as! String
                }
            }
        }
        return displayString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerType! == eMonthOnTheCount) {
            let weekDayIndex = contentArray?.objectAtIndex(pickerView.selectedRowInComponent(0)) as? String
            let weekday = weekDaysArray.objectAtIndex(pickerView.selectedRowInComponent(1)) as? String
            let monthValue = NSString(format: "%@ %@", weekDayIndex!, weekday!)
            pickerCompletion(monthValue)
        } else {
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

