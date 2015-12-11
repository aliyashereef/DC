//
//  DCSChedulingTimePickerCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/11/15.
//
//

import UIKit

typealias SelectedTimePickerContent = NSString? -> Void

class DCSChedulingTimePickerCell: UITableViewCell {

    @IBOutlet weak var schedulingTimePickerView: UIDatePicker!
    var timePickerCompletion: SelectedTimePickerContent = { value in }
    var isStartTimePicker : Bool?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configureTimePickerProperties()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTimePickerProperties() {
        
        //time picker properties
        let locale = NSLocale.init(localeIdentifier: NETHERLANDS_LOCALE)
        schedulingTimePickerView.locale = locale
    }
    
    @IBAction func timePickerValueChanged(sender: AnyObject) {
        
        //time picker value selection
        print("** time selected is %@", schedulingTimePickerView.date)
        let selectedTime = DCDateUtility.timeStringInTwentyFourHourFormat(schedulingTimePickerView.date)
        timePickerCompletion(selectedTime)
    }
}
