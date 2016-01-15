//
//  DCInfusionsAdministerAsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/13/16.
//
//

import UIKit

let ADMINISTER_AS_SECTION_COUNT : NSInteger = 1
let ADMINISTER_AS_ROW_COUNT : NSInteger = 3

protocol InfusionAdministerDelegate {
    
    func administerAsOptionSelected(option : NSString)
}


class DCInfusionsAdministerAsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var administerOptionsTableView: UITableView!
    var optionsArray : [String]? = []
    var previousAdministerOption : String? = EMPTY_STRING
    var administerDelegate : InfusionAdministerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("ADMINISTER_AS", comment: "screen title")
        optionsArray = [BOLUS_INJECTION, DURATION_BASED_INFUSION, RATE_BASED_INFUSION]
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK : TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return ADMINISTER_AS_SECTION_COUNT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ADMINISTER_AS_ROW_COUNT
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let optionsCell = tableView.dequeueReusableCellWithIdentifier(INFUSIONS_ADMINISTER_AS_CELL_ID) as? DCInfusionsAdministerAsCell
        let option = optionsArray![indexPath.item]
        optionsCell?.titleLabel.text = option
        optionsCell?.accessoryType = (option == previousAdministerOption) ? .Checkmark : .None
        return optionsCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let delegate = administerDelegate {
            delegate.administerAsOptionSelected(optionsArray![indexPath.row])
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

}
