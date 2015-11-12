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
        
        if (self.detailType == eSchedulingType) {
            self.title = NSLocalizedString("SCHEDULING", comment:"")
        }
    }
    
    func prepareViewElements() {
        
        //set view properties and values
        detailTableView.layoutMargins = UIEdgeInsetsZero;
        detailTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    func populateDisplayArray() {
        
        //populate display array
        if (self.detailType == eSchedulingType) {
            displayArray = [SPECIFIC_TIMES, INTERVAL]
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
        
        let schedulingCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(SCHEDULING_CELL_ID, forIndexPath: indexPath)
        schedulingCell?.layoutMargins = UIEdgeInsetsZero
        schedulingCell?.textLabel?.font = UIFont.systemFontOfSize(15.0)
        let displayString = displayArray.objectAtIndex(indexPath.item) as? String
        schedulingCell?.accessoryType = (displayString == previousFilledValue) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        schedulingCell?.textLabel?.text = displayString
        return schedulingCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedEntry(displayArray.objectAtIndex(indexPath.item) as! String)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
