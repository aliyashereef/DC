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
    var monthArray : NSArray?
    var previousFilledValue : NSString?
    var repeatValue : DCRepeat?
    var pickerCompletion: SelectedPickerContent = { value in }
        
    func configurePickerCellForPickerType(type : PickerType) {
        
        pickerType = type
        populateContentArrays()
        pickerView.reloadAllComponents()
        selectPickerViewPreviousComponents()
    }
    
    func populateContentArrays() {
        
        contentArray = NSMutableArray()
        if (pickerType! == eSchedulingFrequency) {
            //scheduling frequency type
            contentArray = [DAILY, WEEKLY, MONTHLY, YEARLY]
        } else if (pickerType! == eDailyCount) {
            //daily count
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(7)
        } else if (pickerType! == eWeeklyCount) {
            // weekly count
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(5)
        } else if (pickerType! == eMonthlyCount) {
            //monthly count
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(12)
        } else if (pickerType! == eMonthEachCount) {
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(31)
        } else if (pickerType! == eMonthOnTheCount) {
            //yearly count
            contentArray = [FIRST, SECOND, THIRD, FOURTH, FIFTH, LAST]
        } else if (pickerType! == eYearlyCount) {
            //yearly count
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(25)
        } else if (pickerType! == eYearEachCount || pickerType! == eDayCount) {
            //yearly each picker view
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(31)
             monthArray = DCDateUtility.monthNames()
        } else if (pickerType! == eYearOnTheCount) {
            //yearly on the picker view
            contentArray = [FIRST, SECOND, THIRD, FOURTH, FIFTH, LAST]
            monthArray = DCDateUtility.monthNames()
        } else if (pickerType! == eHoursCount) {
            //hours count
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(24)
        } else if (pickerType! == eMinutesCount) {
            //minutes count
            contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(60)
        }
    }
    
    func configurePickerViewForSchedulingFrequency() {
        
        //scheduling frequency type
        if let repeatType = repeatValue?.repeatType {
            let selectedIndex = contentArray?.indexOfObject(repeatType)
            [pickerView .selectRow(selectedIndex!, inComponent: 0, animated: true)]
        }
    }
    
    func configurePickerViewForDailyCount() {
        
        //daily count
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
    
    func configurePickerViewForYearlyCount() {
        
        //yearly count
        if let yearlyFrequency = repeatValue?.frequency {
            if let range = yearlyFrequency.rangeOfString(" ") {
                let yearlyCount = yearlyFrequency.substringToIndex(range.startIndex)
                let selectedIndex = contentArray?.indexOfObject(Int(yearlyCount)!)
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
    
    func selectPickerViewPreviousComponents() {
        
        //select picker view component
        
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
        } else if (pickerType! == eYearlyCount) {
            configurePickerViewForYearlyCount()
        } else if (pickerType! == eYearEachCount) {
            configureYearlyEachPickerView()
        } else if (pickerType! == eYearOnTheCount) {
            configureYearlyOnThePickerView()
        }
    }
    
    // MARK: Picker Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        if (pickerType! == eSchedulingFrequency || pickerType! == eMonthEachCount || pickerType! == eDayCount) {
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
                if (pickerType! == eDailyCount) {
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

