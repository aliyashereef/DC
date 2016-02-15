//
//  DCReviewDatePickerCell.swift
//  DrugChart
//
//  Created by aliya on 28/01/16.
//
//

import Foundation

class DCReviewDatePickerCell:UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerType : PickerType = eDailyCount
    var weekDaysArray : NSArray?
    var monthArray : NSArray?
    var dayArray : NSArray?
    var selectedValue : String = EMPTY_STRING
    var secondValue : String = EMPTY_STRING
    var contentArray : NSMutableArray?

    var pickerCompletion: SelectedPickerContent = { value in }

    func configurePickerCell() {
        populateContentArrays()
        pickerView.reloadAllComponents()
//        selectPickerViewPreviousComponents()

    }
    
    func populateContentArrays() {
        
        contentArray = NSMutableArray()
        contentArray = [DAY, WEEK, MONTH]
        dayArray = DCSchedulingHelper.numbersArrayWithMaximumCount(DAYS_IN_WEEK_COUNT)
        weekDaysArray = DCSchedulingHelper.numbersArrayWithMaximumCount(WEEKS_IN_MONTH_COUNT)
        monthArray = DCSchedulingHelper.numbersArrayWithMaximumCount(MONTHS_IN_YEAR_COUNT)
    }
    // MARK: Picker Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(component){
        case 0:
            switch (pickerType.rawValue) {
                case eDailyCount.rawValue :
                    return (dayArray?.count)!;
                case eWeeklyCount.rawValue :
                    return (weekDaysArray?.count)!;
                case eMonthlyCount.rawValue :
                    return (monthArray?.count)!;
            default:
                return 0;
            }
        case 1:
            return (contentArray?.count)!
        default:
        return 0;
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var displayString : String = EMPTY_STRING
        switch (component) {
        case 0:
            if (pickerType == eDailyCount) {
                displayString = String((dayArray?.objectAtIndex(row))!)
            } else if (pickerType == eWeeklyCount) {
                displayString = String((weekDaysArray?.objectAtIndex(row))!)
            } else if (pickerType == eMonthlyCount) {
                displayString = String((monthArray?.objectAtIndex(row))!)
            }
            break;
        case 1:
            let valueToDisplay = String((self.contentArray?.objectAtIndex(row))!)
            displayString = String(valueToDisplay);
            break;
        default:
            break;
        }
        return displayString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        switch (component) {
        case 1:
            if (row == 0) {
                pickerType = eDailyCount
                secondValue = "day"
            } else if (row == 1) {
                pickerType = eWeeklyCount
                secondValue = "week"
            } else if (row  == 2) {
                pickerType = eMonthlyCount
                secondValue = "month"
            }
            pickerView.reloadComponent(0)
            break;
        case 0:
            switch (pickerType.rawValue) {
            case eDailyCount.rawValue :
                selectedValue = String((dayArray?.objectAtIndex(row))!)
            case eWeeklyCount.rawValue :
                selectedValue = String((weekDaysArray?.objectAtIndex(row))!)
            case eMonthlyCount.rawValue :
                selectedValue = String((monthArray?.objectAtIndex(row))!)
                break;
            default:
                break;
            }
        default:
            break;
        }
        let displayValue = NSString(format: "Every %@ %@", selectedValue,secondValue )
        pickerCompletion(displayValue)
    }
}

