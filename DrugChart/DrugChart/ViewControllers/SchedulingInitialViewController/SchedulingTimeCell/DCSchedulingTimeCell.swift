//
//  DCSchedulingTimeCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/9/15.
//
//

import UIKit

class DCSchedulingTimeCell: UITableViewCell {
    
    @IBOutlet weak var timeTypeLabel: UILabel! //title
    @IBOutlet weak var timeValueLabel: UILabel! // selected value
    @IBOutlet weak var timeSwitch: UISwitch! // switch to set/unset start&endtime

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
        self.accessoryType = .DisclosureIndicator
    }
    
    func configureSetStartAndEndTimeCell() {
        
        //configure cell with switch element in it
        timeSwitch.hidden = false
        timeSwitch.on = true
        timeTypeLabel.text = NSLocalizedString("SET_START_END_TIME", comment: "")
    }
        
    //MARK: Action Methods
    @IBAction func timeSwitchValueChanged(sender: AnyObject) {
        
        print("**** Set Start & End Time *** %d", timeSwitch.on)
    }

}
