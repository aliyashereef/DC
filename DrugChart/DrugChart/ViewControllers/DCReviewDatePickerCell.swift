//
//  DCReviewDatePickerCell.swift
//  DrugChart
//
//  Created by aliya on 28/01/16.
//
//

import Foundation

class DCReviewDatePickerCell:UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource  {
    // MARK: Picker Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let displayString : String = EMPTY_STRING
        return displayString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }

}
