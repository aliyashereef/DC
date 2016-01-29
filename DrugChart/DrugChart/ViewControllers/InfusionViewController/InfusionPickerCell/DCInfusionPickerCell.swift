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


typealias InfusionPickerCompletion = String? -> Void

class DCInfusionPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var contentArray : NSMutableArray?
    var selectionCompletion : InfusionPickerCompletion = { value in }
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
            let initialValue = DCInfusionsHelper.infusionPickerInitialValueForPickerType(infusionPickerType)
            selectionCompletion(initialValue as String)
            pickerView.selectRow(PickerRowCount.eZerothRow.rawValue, inComponent: PickerComponentsCount.eZerothComponent.rawValue, animated: true)
        } else {
            if (infusionPickerType == eUnit || infusionPickerType == eRateNormal) {
                let selectedIndex = Int(previousValue!)
                pickerView.selectRow(selectedIndex! - 1, inComponent: PickerComponentsCount.eZerothComponent.rawValue, animated: true);
            } else {
                if let flowValue = previousValue {
                    let previousArray = flowValue.componentsSeparatedByString(" ")
                    let initialComponentValue = previousArray[0]
                    let initialIndex = contentArray?.indexOfObject(Int(initialComponentValue)!)
                    [pickerView .selectRow(initialIndex!, inComponent: PickerComponentsCount.eZerothComponent.rawValue, animated: true)]
                    let finalComponentValue = previousArray[1]
                    if (infusionPickerType == eFlowDuration || infusionPickerType == eRateStarting) {
                        let secondComponentRowIndex : NSInteger
                        if (infusionPickerType == eFlowDuration) {
                            secondComponentRowIndex = (finalComponentValue == HOUR || finalComponentValue == HOURS) ? PickerRowCount.eZerothRow.rawValue : PickerRowCount.eFirstRow.rawValue
                        } else {
                            secondComponentRowIndex = (finalComponentValue == MG_PER_HOUR) ? PickerRowCount.eZerothRow.rawValue : PickerRowCount.eFirstRow.rawValue
                        }
                        [pickerView .selectRow(secondComponentRowIndex, inComponent: PickerComponentsCount.eFirstComponent.rawValue, animated: true)]
                    }
                }
            }
            selectionCompletion(previousValue)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return  (infusionPickerType == eFlowDuration || infusionPickerType == eRateStarting) ? PickerComponentsCount.eSecondComponent.rawValue : PickerComponentsCount.eFirstComponent.rawValue
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
                if (infusionPickerType == eFlowDuration) {
                    return (firstComponentValue === 1) ? HOUR : HOURS
                } else {
                    return MG_PER_HOUR
                }
            } else {
                if (infusionPickerType == eFlowDuration) {
                    return (firstComponentValue === 1) ? MINUTE : MINUTES
                } else {
                    return MG_PER_MINUTE
                }
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let content = NSMutableString()
        let value = contentArray!.objectAtIndex(pickerView.selectedRowInComponent(0))
        content.appendString("\(value)")
        if (pickerView.numberOfComponents > PickerComponentsCount.eFirstComponent.rawValue) {
            let selectedRow = pickerView.selectedRowInComponent(PickerComponentsCount.eFirstComponent.rawValue)
            if (infusionPickerType == eFlowDuration) {
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
            } else {
                if (selectedRow == 0) {
                    content.appendFormat(" %@", MG_PER_HOUR)
                } else {
                    content.appendFormat(" %@", MG_PER_MINUTE)
                }
            }
            pickerView.reloadAllComponents()
        }
        selectionCompletion(content as String)
    }
}
