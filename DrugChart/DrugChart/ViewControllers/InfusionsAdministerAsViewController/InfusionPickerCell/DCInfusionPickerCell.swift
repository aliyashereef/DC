//
//  DCInfusionPickerCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/15/16.
//
//

import UIKit

enum PickerComponentsCount : NSInteger {
    
    // enum for Section Count
    case eZerothComponent = 0
    case eFirstComponent
    case eSecondComponent
}

enum PickerRowCount : NSInteger {
    
    //enum for row count
    case eZerothRow = 0
    case eFirstRow
    case eSecondRow
}


typealias InfusionUnitCompletion = String? -> Void

class DCInfusionPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var contentArray : NSMutableArray?
    var unitCompletion : InfusionUnitCompletion = { value in }
    var previousValue : String?
    var infusionPickerType : InfusionPickerType?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configurePickerView () {
        
        contentArray = DCSchedulingHelper.numbersArrayWithMaximumCount(250)
        pickerView.reloadAllComponents()
        if (previousValue == nil) {
            let initialValue = (infusionPickerType == eUnit) ? ONE : "1 hour"
            unitCompletion(initialValue)
            pickerView.selectRow(PickerRowCount.eZerothRow.rawValue, inComponent: PickerComponentsCount.eZerothComponent.rawValue, animated: true)
        } else {
            if (infusionPickerType == eUnit) {
                let selectedIndex = Int(previousValue!)
                pickerView.selectRow(selectedIndex! - 1, inComponent: PickerComponentsCount.eZerothComponent.rawValue, animated: true);
            } else {
                if let flowValue = previousValue {
                    if let range = flowValue.rangeOfString(" ") {
                        let flowDuration = flowValue.substringToIndex(range.startIndex)
                        let selectedIndex = contentArray?.indexOfObject(Int(flowDuration)!)
                        [pickerView .selectRow(selectedIndex!, inComponent: PickerComponentsCount.eZerothComponent.rawValue, animated: true)]
                    }
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return  (infusionPickerType == eUnit) ? PickerComponentsCount.eFirstComponent.rawValue : PickerComponentsCount.eSecondComponent.rawValue
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == PickerComponentsCount.eZerothComponent.rawValue {
            return (contentArray?.count)!
        } else {
            return PickerRowCount.eSecondRow.rawValue
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            let content = String((contentArray?.objectAtIndex(row))!)
            return content
        } else {
            let firstComponentValue = contentArray?.objectAtIndex(pickerView.selectedRowInComponent(PickerRowCount.eZerothRow.rawValue))
            if row == PickerRowCount.eZerothRow.rawValue {
                return (firstComponentValue === 1) ? HOUR : HOURS
            } else {
                return (firstComponentValue === 1) ? MINUTE : MINUTES
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let content = NSMutableString()
        let value = contentArray?.objectAtIndex(row) as! NSNumber
        content.appendString("\(value)")
        if (pickerView.numberOfComponents > PickerComponentsCount.eFirstComponent.rawValue) {
            let selectedRow = pickerView.selectedRowInComponent(PickerComponentsCount.eFirstComponent.rawValue)
            if (selectedRow == 0) {
                if (content == ONE) {
                    content.appendFormat(" %@", HOUR)
                } else {
                    content.appendFormat(" %@", HOURS)
                }
            } else {
                if (content == ONE) {
                    content.appendFormat(" %@", MINUTE)
                } else {
                    content.appendFormat(" %@", MINUTES)
                }
            }
            pickerView.reloadAllComponents()
        }
        unitCompletion(content as String)
    }
}
