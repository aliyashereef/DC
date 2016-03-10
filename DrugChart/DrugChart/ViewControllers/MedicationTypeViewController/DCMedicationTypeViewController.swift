//
//  DCMedicationTypeViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/10/16.
//
//

import UIKit

typealias SelectedTypeValue = NSString? -> Void

class DCMedicationTypeViewController: UITableViewController {
    
    var displayArray : [String]?
    var previousValue : String?
    
    var typeCompletion: SelectedTypeValue = { value in }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("TYPE", comment: "screen title")
        populateDisplayArray()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateDisplayArray () {
        
        displayArray = [REGULAR_MEDICATION, ONCE_MEDICATION, WHEN_REQUIRED_VALUE];
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (displayArray?.count)!
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TYPE_CELL_ID, forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        let displayString = displayArray![indexPath.row]
        cell.textLabel?.text = displayString
        cell.accessoryType = (displayString == previousValue) ? .Checkmark : .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedValue = displayArray![indexPath.item]
        typeCompletion(selectedValue)
        self.navigationController?.popToRootViewControllerAnimated(true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
