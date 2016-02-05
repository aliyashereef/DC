//
//  DCSchedulingTimeCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/9/15.
//
//

import UIKit

protocol SchedulingTimeCellDelegate {
    
    func setStartEndTimeSwitchValueChanged(state : Bool)
}

class DCSchedulingTimeCell: UITableViewCell {
    
    @IBOutlet weak var timeTypeLabel: UILabel! //title
    @IBOutlet weak var timeValueLabel: UILabel! // selected value
    @IBOutlet weak var timeSwitch: UISwitch! // switch to set/unset start&endtime
    var schedulingCellDelegate : SchedulingTimeCellDelegate?
    //var previousPickerState : Bool?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Public Methods
    
    func configureTimeCellForTimeType(type : String, withSelectedValue value : String) {
        
        // configure noraml cell with title and description values
        timeSwitch.hidden = true
        timeTypeLabel.text = type
        timeValueLabel.text = value
        timeValueLabel.hidden = false
        self.accessoryType = .DisclosureIndicator
    }
    
    func configureSetStartAndEndTimeCellForSwitchState(state : Bool) {
        
        //configure cell with switch element in it
        timeSwitch.hidden = false
        //timeSwitch.on = previousPickerState!
        timeSwitch.on = state
        timeValueLabel.hidden = true
        timeTypeLabel.text = NSLocalizedString("SET_START_END_TIME", comment: "")
        self.accessoryType = .None
    }
        
    //MARK: Action Methods
    @IBAction func timeSwitchValueChanged(sender: AnyObject) {
        
       // let switchState = timeSwitch.on;
        //if switchState != previousPickerState {
            if let delegate = schedulingCellDelegate {
                delegate.setStartEndTimeSwitchValueChanged(timeSwitch.on)
            }
          //  previousPickerState = switchState
       // }
    }

}
