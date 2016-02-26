//
//  DCSchedulingPickerCell.swift
//  DrugChart
//
//  Created by Jilu mary Joy on 11/13/15.
//
//

import UIKit

let DAYS_IN_WEEK_COUNT : NSInteger = 4
let WEEKS_IN_MONTH_COUNT : NSInteger = 4
let MONTHS_IN_YEAR_COUNT : NSInteger = 11
let DAYS_IN_MONTH_COUNT : NSInteger = 31
let MAX_YEAR : NSInteger = 5
let HOURS_IN_DAY_COUNT : NSInteger = 24
let MINIUTES_IN_HOURS_COUNT : NSInteger = 60

typealias SelectedPickerContent = NSString? -> Void

class DCSchedulingPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    var pickerType : PickerType?
    var contentArray : NSMutableArray?
    var weekDaysArray : NSArray?
    var monthArray : NSArray?
    var previousFilledValue : NSString?
    var repeatValue : DCRepeat?
    var interval : DCInterval?
    var pickerCompletion: SelectedPickerContent = { value in }
        
    func configurePickerCellForPickerType(type : PickerType) {
        
        pickerType = type
        populateContentArrays()
        pickerView.reloadAllComponents()
        selectPickerViewPreviousComponents()
    }
    
    func populateContentArrays() {
        
        contentArray = NSMutableArray()
        switch (pickerType!.rawValue) {
            case eSchedulingFrequency.rawValue :
                //scheduling frequency type
                contentArray = [DAILY, WEEKLY, MONTHLY, YEARLY]
            case eDailyCount.rawValue :
                //daily count
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(DAYS_IN_WEEK_COUNT)
            case eWeeklyCount.rawValue :
                // weekly count
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(WEEKS_IN_MONTH_COUNT)
            case eMonthlyCount.rawValue :
                //monthly count
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(MONTHS_IN_YEAR_COUNT)
            case eMonthEachCount.rawValue :
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(DAYS_IN_MONTH_COUNT)
            case eMonthOnTheCount.rawValue :
                contentArray = [FIRST, SECOND, THIRD, FOURTH, FIFTH, LAST]
            case eYearlyCount.rawValue :
                //yearly count
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(MAX_YEAR)
            case eYearEachCount.rawValue :
                //yearly each picker view
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(DAYS_IN_MONTH_COUNT)
                monthArray = DCDateUtility.monthNames()
            case eYearOnTheCount.rawValue :
                //yearly on the picker view
                contentArray = [FIRST, SECOND, THIRD, FOURTH, FIFTH, LAST]
                monthArray = DCDateUtility.monthNames()
            case eHoursCount.rawValue :
                //hours count
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(HOURS_IN_DAY_COUNT)
            case eMinutesCount.rawValue :
                //minutes count
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(MINIUTES_IN_HOURS_COUNT)
            case eDayCount.rawValue :
                contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(DAYS_IN_MONTH_COUNT)
            default :
                break
        }
    }
    
    func configurePickerViewForSchedulingFrequency() {
        
        //scheduling frequency type
        if let repeatType = repeatValue?.repeatType {
            let selectedIndex = contentArray?.indexOfObject(repeatType)
            [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
        }
    }
    
    func configurePickerViewForDailyOrWeeklyFrequencyCount() {
        
        //daily count
        if let frequency = repeatValue?.frequency {
            if let range = frequency.rangeOfString(" ") {
                let frequencyCount = frequency.substringToIndex(range.startIndex)
                let selectedIndex = contentArray?.indexOfObject(Int(frequencyCount)!)
                [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
            }
        }
    }
    
    func configurePickerViewForMonthlyOrYearlyCount() {
        
        //monthly count
        if let frequency = repeatValue?.frequency {
            if let range = frequency.rangeOfString(" ") {
                let frequencyCount = frequency.substringToIndex(range.startIndex)
                let selectedIndex = contentArray?.indexOfObject(Int(frequencyCount)!)
                [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
            } else {
                [pickerView .selectRow(0, inComponent: 0, animated: true)]
            }
        }
    }
    
    func configureMonthlyEachPickerView() {
        
        if let monthEach = repeatValue?.eachValue {
            let selectedIndex = contentArray?.indexOfObject(Int(monthEach)!)
            [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
        }
    }
    
    func configureMonthlyOnThePickerView() {
        
        if let monthOnThe = repeatValue?.onTheValue {
            if (monthOnThe != EMPTY_STRING) {
                let (indexValue, weekDay) = DCSchedulingHelper.splitComponentsSeparatedBySpace(monthOnThe)
                let firstComponentIndex = contentArray?.indexOfObject(indexValue)
                [pickerView.selectRow(firstComponentIndex!, inComponent: 0, animated: true)]
                let secondComponentIndex = weekDaysArray?.indexOfObject(weekDay)
                if (pickerView.numberOfComponents == 2) {
                    [pickerView.selectRow(secondComponentIndex!, inComponent: 1, animated: true)]
                }
            }
        }
    }
    
    func configureYearlyEachPickerView() {
        
        //yearly each picker view
        if let yearEachValue = repeatValue?.yearEachValue {
            if (yearEachValue != EMPTY_STRING) {
                let (day, month) = DCSchedulingHelper.splitComponentsSeparatedBySpace(yearEachValue)
                let firstComponentIndex = contentArray?.indexOfObject(Int(day as String)!)
                [pickerView.selectRow(firstComponentIndex!, inComponent: 0, animated: true)]
                let secondComponentIndex = monthArray?.indexOfObject(month)
                if (pickerView.numberOfComponents == 2) {
                    [pickerView.selectRow(secondComponentIndex!, inComponent: 1, animated: true)]
                }
            }
        }
    }
    
    func configureYearlyOnThePickerView() {
        
        //yearly on the picker view
        if let yearOnThe = repeatValue?.yearOnTheValue {
            if (yearOnThe != EMPTY_STRING) {
                let components = yearOnThe.componentsSeparatedByString(" ")
                let indexValue = components[0]
                let weekDay = components[1]
                let month = components[2]
                let firstComponentIndex = contentArray?.indexOfObject(indexValue)
                [pickerView.selectRow(firstComponentIndex!, inComponent: 0, animated: true)]
                if (pickerView.numberOfComponents == 3) {
                    let secondComponentIndex = weekDaysArray?.indexOfObject(weekDay)
                    [pickerView.selectRow(secondComponentIndex!, inComponent: 1, animated: true)]
                    let thirdComponentIndex = monthArray?.indexOfObject(month)
                    [pickerView.selectRow(thirdComponentIndex!, inComponent: 2, animated: true)]
                }
            }
        }
    }
    
    func configureIntervalPickerView() {
        
        //day interval picker view
        let repeatFrequency : String?
        if (interval?.repeatFrequencyType == DAYS_TITLE) {
            repeatFrequency = interval?.daysCount
        } else if (interval?.repeatFrequencyType == HOURS_TITLE) {
            repeatFrequency = interval?.hoursCount
        } else {
            repeatFrequency = interval?.minutesCount
        }
        if let dayInterval = repeatFrequency {
            let selectedIndex = contentArray?.indexOfObject(Int(dayInterval)!)
            [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
        } else {
            [pickerView .selectRow(0, inComponent: 0, animated: true)]
        }
    }
    
    func selectPickerViewPreviousComponents() {
        
        //select picker view component
        switch (pickerType!.rawValue) {
            case eSchedulingFrequency.rawValue :
                configurePickerViewForSchedulingFrequency()
            case eDailyCount.rawValue,
                eWeeklyCount.rawValue :
               configurePickerViewForDailyOrWeeklyFrequencyCount()
            case eMonthlyCount.rawValue,
                eYearlyCount.rawValue :
                configurePickerViewForMonthlyOrYearlyCount()
            case eMonthEachCount.rawValue :
                configureMonthlyEachPickerView()
            case eMonthOnTheCount.rawValue :
                configureMonthlyOnThePickerView()
            case eYearEachCount.rawValue :
                configureYearlyEachPickerView()
            case eYearOnTheCount.rawValue :
                configureYearlyOnThePickerView()
            case eDayCount.rawValue,
                eHoursCount.rawValue,
                eMinutesCount.rawValue :
                configureIntervalPickerView()
            default :
                break
        }
    }
    
    // MARK: Picker Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        if (pickerType! == eSchedulingFrequency || pickerType! == eMonthEachCount) {
            return 1
        } else if (pickerType! == eYearOnTheCount) {
            return 3
        } else {
            return 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (component == 0) {
            return (contentArray?.count)!
        } else if (component == 1) {
            if (pickerType! == eMonthOnTheCount || pickerType! == eYearOnTheCount) {
                return weekDaysArray!.count
            } else if (pickerType! == eYearEachCount) {
                return monthArray!.count
            } else {
                return 1
            }
        } else {
            return monthArray!.count
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
            } else if (component == 1) {
                let firstComponentValue = contentArray?.objectAtIndex(pickerView.selectedRowInComponent(0))
                if (pickerType! == eDailyCount || pickerType! == eDayCount) {
                    displayString = (firstComponentValue === 1) ? DAY : DAYS
                } else if (pickerType! == eWeeklyCount) {
                    displayString = (firstComponentValue === 1) ? WEEK : WEEKS
                } else if (pickerType! == eMonthlyCount) {
                    displayString = (firstComponentValue === 1) ? MONTH : MONTHS
                } else if (pickerType! == eYearlyCount) {
                    displayString = (firstComponentValue === 1) ? YEAR : YEARS
                } else if (pickerType! == eMonthOnTheCount || pickerType! == eYearOnTheCount) {
                    displayString = weekDaysArray!.objectAtIndex(row) as! String
                } else if (pickerType! == eYearEachCount) {
                    displayString = monthArray!.objectAtIndex(row) as! String
                } else if (pickerType! == eHoursCount) {
                    displayString = (firstComponentValue === 1) ? HOUR : HOURS
                } else if (pickerType! == eMinutesCount) {
                    displayString = (firstComponentValue === 1) ? MINUTE : MINUTES
                }
            } else {
                displayString = monthArray!.objectAtIndex(row) as! String
            }
        }
        return displayString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerType! == eMonthOnTheCount || pickerType! == eYearEachCount) {
            let initialValue = String((contentArray?.objectAtIndex(pickerView.selectedRowInComponent(0)))!)
            var secondValue : String?
            if (pickerType! == eMonthOnTheCount) {
                secondValue = weekDaysArray!.objectAtIndex(pickerView.selectedRowInComponent(1)) as? String
            } else {
                secondValue = monthArray!.objectAtIndex(pickerView.selectedRowInComponent(1)) as? String
            }
            let displayValue = NSString(format: "%@ %@", initialValue, secondValue!)
            pickerCompletion(displayValue)
        } else if (pickerType! == eYearOnTheCount) {
            let day = String((contentArray?.objectAtIndex(pickerView.selectedRowInComponent(0)))!)
            let weekDay = weekDaysArray!.objectAtIndex(pickerView.selectedRowInComponent(1)) as? String
            let month = monthArray?.objectAtIndex(pickerView.selectedRowInComponent(2)) as? String
            let displayValue = NSString(format: "%@ %@ %@", day, weekDay!, month!)
            pickerCompletion(displayValue)
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

