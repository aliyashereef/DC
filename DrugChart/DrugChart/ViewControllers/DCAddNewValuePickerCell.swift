//
//  DCAddNewValuePickerCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 03/02/16.
//
//

import UIKit

typealias ValueSelectionCompleted = String? -> Void

class DCAddNewValuePickerCell: UITableViewCell , UIPickerViewDelegate, UIPickerViewDataSource {
    
    var unitArrayForDisplay = [String]()
    var pickerCompletion: ValueSelectionCompleted = { value in }
    var selectedContent : String = ""
    @IBOutlet weak var unitPickerCell: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configurePickerCellWithValues(unitArray : [String]) {
        
        unitArrayForDisplay = unitArray
        unitPickerCell.reloadAllComponents()
    }
    
    func currentValueForPickerCell (type : PickerType) {
        
        //To return selected value on first click.
    }
        
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return unitArrayForDisplay.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return unitArrayForDisplay[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedContent = unitArrayForDisplay[pickerView.selectedRowInComponent(0)]
        pickerCompletion(selectedContent)
    }
}
