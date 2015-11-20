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
    var weekDaysArray : NSArray?
    var previousFilledValue : NSString?
    var repeatValue : DCRepeat?
    var pickerCompletion: SelectedPickerContent = { value in }
        
    func configurePickerCellForPickerType(type : PickerType) {
        
        pickerType = type
        contentArray = NSMutableArray()
        if (pickerType! == eSchedulingFrequency) {
            configurePickerViewForSchedulingFrequency()
        } else if (pickerType! == eDailyCount) {
            configurePickerViewForDailyCount()
        } else if (pickerType! == eWeeklyCount) {
            configurePickerViewForWeeklyCount()
        } else if (pickerType! == eMonthlyCount) {
            configurePickerViewForMonthlyCount()
        } else if (pickerType! == eMonthEachCount) {
            configureMonthlyEachPickerView()
        } else if (pickerType! == eMonthOnTheCount) {
            configureMonthlyOnThePickerView()
        }
        pickerView.reloadAllComponents()
    }
    
    func configurePickerViewForSchedulingFrequency() {
        
        //scheduling frequency type
        contentArray = [DAILY, WEEKLY, MONTHLY, YEARLY]
        if let repeatType = repeatValue?.repeatType {
            let selectedIndex = contentArray?.indexOfObject(repeatType)
            [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
        }
    }
    
    func configurePickerViewForDailyCount() {
        
        //daily count
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
    }
    
    func configurePickerViewForWeeklyCount() {
        
        // weekly count
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
    }
    func configurePickerViewForMonthlyCount() {
        
        //monthly count
        for number : NSInteger in 1...12 {
            [contentArray?.addObject(number)]
        }
        if let monthlyFrequency = repeatValue?.frequency {
            if let range = monthlyFrequency.rangeOfString(" ") {
                let monthlyCount = monthlyFrequency.substringToIndex(range.startIndex)
                let selectedIndex = contentArray?.indexOfObject(Int(monthlyCount)!)
                [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
            } else {
                [pickerView .selectRow(0, inComponent: 0, animated: true)]
            }
        }
    }
    
    func configureMonthlyEachPickerView() {
        
        for number : NSInteger in 1...31 {
            [contentArray?.addObject(number)]
        }
        if let monthEach = repeatValue?.eachValue {
            let selectedIndex = contentArray?.indexOfObject(Int(monthEach)!)
            [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
        }
    }
    
    func configureMonthlyOnThePickerView() {
        
        contentArray = [FIRST, SECOND, THIRD, FOURTH, FIFTH, LAST]
        if let monthOnThe = repeatValue?.onTheValue {
            if (monthOnThe != EMPTY_STRING) {
                let (indexValue, weekDay) = DCSchedulingHelper.splitMonthOnTheValues(monthOnThe)
                let firstComponentIndex = contentArray?.indexOfObject(indexValue)
                [pickerView.selectRow(firstComponentIndex!, inComponent: 0, animated: true)]
                let secondComponentIndex = weekDaysArray?.indexOfObject(weekDay)
                if (pickerView.numberOfComponents == 2) {
                    [pickerView.selectRow(secondComponentIndex!, inComponent: 1, animated: true)]
                }
            }
        }
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
            return (pickerType! == eMonthOnTheCount) ? (weekDaysArray!.count) : 1
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var displayString : String = EMPTY_STRING
        if (pickerType! == eSchedulingFrequency) {
            displayString = contentArray?.objectAtIndex(row) as! String
        } else {
            if (component == 0) {
                let valueToDisplay = String((contentArray?.objectAtIndex(row))!)
                displayString = String(valueToDisplay)
            } else {
                let firstComponentValue = contentArray?.objectAtIndex(pickerView.selectedRowInComponent(0))
                if (pickerType! == eDailyCount) {
                    displayString = (firstComponentValue === 1) ? DAY : "days"
                } else if (pickerType! == eWeeklyCount) {
                    displayString = (firstComponentValue === 1) ? "week" : "weeks"
                } else if (pickerType! == eMonthlyCount) {
                    displayString = (firstComponentValue === 1) ? "month" : "months"
                } else if (pickerType! == eMonthOnTheCount) {
                    displayString = weekDaysArray!.objectAtIndex(row) as! String
                }
            }
        }
        return displayString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerType! == eMonthOnTheCount) {
            let weekDayIndex = contentArray?.objectAtIndex(pickerView.selectedRowInComponent(0)) as? String
            let weekday = weekDaysArray!.objectAtIndex(pickerView.selectedRowInComponent(1)) as? String
            let monthValue = NSString(format: "%@ %@", weekDayIndex!, weekday!)
            pickerCompletion(monthValue)
        } else {
            var selectedValue : String = EMPTY_STRING
            if (pickerType! == eSchedulingFrequency) {
                selectedValue = (contentArray?.objectAtIndex(row) as? String)!
                pickerCompletion(selectedValue)
            } else {
                let valueToDisplay = String((contentArray?.objectAtIndex(row))!)
                selectedValue = String(valueToDisplay)
                pickerCompletion(selectedValue)
            }
        }
    }
}

