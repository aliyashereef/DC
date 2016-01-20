//
//  DCInfusionPickerCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/15/16.
//
//

import UIKit

typealias InfusionUnitCompletion = String? -> Void

class DCInfusionPickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var contentArray : NSMutableArray?
    var unitCompletion : InfusionUnitCompletion = { value in }
    var previousValue : String?
    
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
            unitCompletion(ONE)
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            let selectedIndex = Int(previousValue!)
            pickerView.selectRow(selectedIndex! - 1, inComponent: 0, animated: true);
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return (contentArray?.count)!
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let content = String((contentArray?.objectAtIndex(row))!)
        return content
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let content = String((contentArray?.objectAtIndex(row))!)
        unitCompletion(content)
    }
    
}
