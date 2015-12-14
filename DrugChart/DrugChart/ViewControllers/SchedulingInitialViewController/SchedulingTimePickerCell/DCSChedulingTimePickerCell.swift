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
    var previousSelectedTime : NSDate?
    
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
    
    func populatePickerWithPreviousSelectedTime() {
        
        if let time = previousSelectedTime {
            print("***** Selecetd time is %@", time);
        } else {
            // previous time is nil
            self.performSelector(Selector("sendUpdatedPickerTimeToSuperView"), withObject: nil, afterDelay: 0.2)
            sendUpdatedPickerTimeToSuperView()
        }
    }
    
    func sendUpdatedPickerTimeToSuperView() {
        
        let timeInCurrentZone  = DCDateUtility.dateInCurrentTimeZone(schedulingTimePickerView.date)
        let selectedTime = DCDateUtility.timeStringInTwentyFourHourFormat(timeInCurrentZone)
        timePickerCompletion(selectedTime)
    }
    
    @IBAction func timePickerValueChanged(sender: AnyObject) {
        
        //time picker value selection
       sendUpdatedPickerTimeToSuperView()
    }
}
