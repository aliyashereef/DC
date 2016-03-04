//
//  DCAdministrationDatePickerCell.swift
//  DrugChart
//
//  Created by aliya on 04/03/16.
//
//

import Foundation
@objc public protocol AdministrationDateDelegate {
    
    func selectedDateAtIndexPath (date : NSDate, indexPath:NSIndexPath)
}

class DCAdministrationDatePickerCell: UITableViewCell {
    
    @IBOutlet var datePicker: UIDatePicker!
    var delegate : AdministrationDateDelegate?
    var selectedIndexPath : NSIndexPath?
    func configureDatePickerPropertiesForAdministrationDate() {
    //configure picker properties
        
    }
    
    @IBAction func valueChanged(sender: AnyObject) {
        if let delegate = delegate {
            delegate.selectedDateAtIndexPath(DCDateUtility.dateInCurrentTimeZone(datePicker.date), indexPath: selectedIndexPath!)
        }
    }
}