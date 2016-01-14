//
//  DCSlowBolusCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/13/16.
//
//

import UIKit

typealias SlowBolusSwitchState = Bool? -> Void

class DCSlowBolusCell: UITableViewCell {

    @IBOutlet weak var bolusSwitch: UISwitch!
    
    var switchState : SlowBolusSwitchState?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func slowBolusSwitchValueChanged(sender: AnyObject) {
        
        // slow bolus switch selection
        print("***** Slow Bolus Switch selection *****")
       // let switchStatus = sender.isOn
        NSLog("**** switchStatus is %@", sender.isOn)
        self.switchState!(sender.isOn)
    }

}
