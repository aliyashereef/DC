//
//  DCDosageUnitSelectionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

typealias ValueForUnitSelected = String? -> Void

class DCDosageUnitSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let dosageUnitItems = ["mg","ml","%"]
    var previousSelectedValue : NSString = ""
    var valueForUnitSelected: ValueForUnitSelected = { value in }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBarItems()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        self.navigationItem.title = DOSE_UNIT_TITLE
        self.title = DOSE_UNIT_TITLE
    }
    
    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let doseUnitCell : DCDosageUnitSelectionTableViewCell? = tableView.dequeueReusableCellWithIdentifier(DOSE_DETAIL_CELL_ID) as? DCDosageUnitSelectionTableViewCell
        doseUnitCell?.accessoryType = (previousSelectedValue == dosageUnitItems[indexPath.row]) ? .Checkmark : .None
            doseUnitCell?.dosageUnitLabel.text = dosageUnitItems[indexPath.row]
            return doseUnitCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.valueForUnitSelected(dosageUnitItems[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
    }

}
