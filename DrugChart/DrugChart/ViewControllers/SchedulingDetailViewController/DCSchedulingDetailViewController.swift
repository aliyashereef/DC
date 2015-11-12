//
//  DCSchedulingDetailViewController.swift
//  DrugChart
//
//  Created by qbuser on 11/11/15.
//
//

import UIKit

class DCSchedulingDetailViewController: DCAddMedicationDetailViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    
    var displayArray : NSMutableArray = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareViewElements()
        populateDisplayArray()
    }
    
    func configureNavigationTitleView() {
        
        if (self.detailType == eDetailSchedulingType) {
            self.title = NSLocalizedString("SCHEDULING", comment:"")
        } else if (self.detailType == eDetailRepeatType) {
            self.title = NSLocalizedString("REPEAT", comment: "")
        }
    }
    
    func prepareViewElements() {
        
        //set view properties and values
        detailTableView.layoutMargins = UIEdgeInsetsZero;
        detailTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    func populateDisplayArray() {
        
        //populate display array
        if (self.detailType == eDetailSchedulingType) {
            displayArray = [SPECIFIC_TIMES, INTERVAL]
        } else if (self.detailType == eDetailRepeatType) {
            displayArray = ["Frequency", "Every"]
        }
    }
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let schedulingCell : DCSchedulingCell? = tableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID) as? DCSchedulingCell
        schedulingCell?.layoutMargins = UIEdgeInsetsZero
        let displayString = displayArray.objectAtIndex(indexPath.item) as? String
        if (self.detailType == eDetailSchedulingType) {
             schedulingCell?.accessoryType = (displayString == previousFilledValue) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            schedulingCell?.descriptionLabel.hidden = true
        } else {
            schedulingCell?.accessoryType = UITableViewCellAccessoryType.None
            schedulingCell?.descriptionLabel.hidden = false
            if (indexPath.row == 0) {
                 schedulingCell?.descriptionLabel.text = DAILY
            } else {
                schedulingCell?.descriptionLabel.text = "1 day"
            }
        }
        schedulingCell?.titleLabel?.text = displayString
        return schedulingCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedEntry(displayArray.objectAtIndex(indexPath.item) as! String)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
}
