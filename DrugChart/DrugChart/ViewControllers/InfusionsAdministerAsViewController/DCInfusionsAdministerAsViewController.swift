//
//  DCInfusionsAdministerAsViewController.swift
//  DrugChart
//
//  Created by qbuser on 1/13/16.
//
//

import UIKit

typealias SelectedInfusionAdministerOption = NSString? -> Void

class DCInfusionsAdministerAsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var administerOptionsTableView: UITableView!
    var optionsArray : [String]? = []
    var previousAdministerOption : String? = EMPTY_STRING
    var optionSelection: SelectedInfusionAdministerOption = { value in }
    
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
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let optionsCell = tableView.dequeueReusableCellWithIdentifier(INFUSIONS_ADMINISTER_AS_CELL_ID) as? DCInfusionsAdministerAsCell
        let option = optionsArray![indexPath.item]
        optionsCell?.titleLabel.text = option
        optionsCell?.accessoryType = (option == previousAdministerOption) ? .Checkmark : .None
        return optionsCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        NSLog("**** Selected option is %@", optionsArray![indexPath.row])
        self.optionSelection(optionsArray![indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }

}
