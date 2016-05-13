//
//  DCSwitchCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/13/16.
//
//

import UIKit

typealias SwitchState = Bool? -> Void

class DCSwitchCell: UITableViewCell {

    @IBOutlet weak var cellSwitch: UISwitch!
    
    var switchState : SwitchState?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchValueChanged(sender: AnyObject) {
        
        // slow bolus switch selection
        self.switchState!(cellSwitch.on)
    }

}
