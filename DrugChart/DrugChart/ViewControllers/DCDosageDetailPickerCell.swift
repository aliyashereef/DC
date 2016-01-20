//
//  DCDosageDetailPickerCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 18/12/15.
//
//

import UIKit

typealias SelectedPickerValue = NSString? -> Void

class DCDosageDetailPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    var pickerType : PickerType?
    var reducingIncreasingArray = ["Reducing","Increasing"]
    var daysCount = ["1","2","3","4","5","6","7"]
    var contentArray = [String]()
    var pickerCompletion: SelectedPickerValue = { value in }
    var selectedContent : String = ""
    var changeOver : String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configurePickerCellForPickerType(type : PickerType) {
        
        pickerType = type
        populateContentArrays()
        pickerView.reloadAllComponents()
    }
    
    func populateContentArrays() {
        
        if (pickerType! == eReducingIncreasingType) {
            
            contentArray = [REDUCING,INCREASING]
        } else {
            
            contentArray = daysCount
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        if (pickerType! == eReducingIncreasingType) {
            
            return 1
        } else {
            
            return 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerType! == eReducingIncreasingType) {
            
            return 2
        } else {
            
            if (component == 0) {
                
                return 7
            } else {
                return 1
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var displayString : String = EMPTY_STRING
        if (pickerType! == eReducingIncreasingType) {
            displayString = String(contentArray[row])
            return displayString
        } else {
            
            if (component == 0) {
                
                displayString = String(contentArray[row])
            } else {
                
                displayString = changeOver.lowercaseString
            }
        }
        return displayString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerType! == eReducingIncreasingType) {
            
            selectedContent = reducingIncreasingArray[pickerView.selectedRowInComponent(0)]
            pickerCompletion(selectedContent)
        } else {
            
            selectedContent = daysCount[pickerView.selectedRowInComponent(0)]
            pickerCompletion(selectedContent)
        }
    }
}
