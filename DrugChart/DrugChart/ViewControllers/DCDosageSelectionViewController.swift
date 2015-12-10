//
//  DCDosageSelectionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 09/12/15.
//
//

import UIKit

let dosageTitle : NSString = "Dose"
let dosageCellID : NSString = "dosagetypecell"
let dosageDetailCellID : NSString = "dosageDetailCell"
let dosageMenuItems = ["Fixed","Variable","Reducing / Increasing","Split Daily"]

class DCDosageSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var detailType : DosageDetailType = eDosageMenu
    var isRowAlreadySelected : Bool = false
    var previousIndexPath = NSIndexPath(forRow: 5, inSection: 0)
    @IBOutlet weak var dosageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBarItems()
        // Do any additional setup after loading the view.
    }

    func configureNavigationBarItems() {
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        self.navigationItem.title = dosageTitle as String
        self.title = dosageTitle as String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (detailType == eDosageMenu) {
            
            return 1
        } else if (detailType == eSplitDaily) {
            
            return 2
        } else {
            
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            
            return 4
        } else if (section == 1) {
            
            switch(detailType.rawValue) {
                
            case eFixedDosage.rawValue:
                return 2
            case eSplitDaily.rawValue:
                return 2 
            case eVariableDosage.rawValue:
                return 3
            case eReducingIncreasing.rawValue:
                return 4
            default:
                break
            }
        } else if (section == 2) {
            
            return 4
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if ( indexPath .section == 0) {
            let dosageSelectionMenuCell : DCDosageSelectionTableViewCell? = dosageTableView.dequeueReusableCellWithIdentifier(dosageCellID as String) as? DCDosageSelectionTableViewCell
            // Configure the cell...
            dosageSelectionMenuCell!.dosageMenuLabel.text = dosageMenuItems[indexPath.row]
            
            if (indexPath.row == previousIndexPath.row && indexPath.section == 0) {
                
                dosageSelectionMenuCell?.accessoryType = .Checkmark
            } else {
                
                dosageSelectionMenuCell?.accessoryType = .None
            }
            return dosageSelectionMenuCell!
        } else {
            
            let dosageSelectionDetailCell : DCDosageSelectionTableViewCell? = dosageTableView.dequeueReusableCellWithIdentifier(dosageDetailCellID as String) as? DCDosageSelectionTableViewCell
            // Configure the cell...
            dosageSelectionDetailCell!.dosageDetailLabel.text = "Dosage Unit"
            dosageSelectionDetailCell!.dosageDetailValueLabel.text = "mg"
            
            return dosageSelectionDetailCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            
            previousIndexPath = indexPath
        }
        tableView.reloadData()
        if (indexPath.section == 0) {
            
            switch (indexPath.row) {
                
            case 0:
                if (detailType == eFixedDosage){
                    
                    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                    isRowAlreadySelected = true
                }else {
                    
                    detailType = eFixedDosage
                }
            case 1:
                if (detailType == eVariableDosage){
                    
                    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                    isRowAlreadySelected = true
                }else {
                    
                    detailType = eVariableDosage
                }
            case 2:
                if (detailType == eReducingIncreasing){
                    
                    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                    isRowAlreadySelected = true
                }else {
                    
                    detailType = eReducingIncreasing
                }
            case 3:
                if (detailType == eSplitDaily){
                    
                    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
                    isRowAlreadySelected = true
                }else {
                    
                    detailType = eSplitDaily
                }
            default:
                break
            }
        }
        if (isRowAlreadySelected == true){
            
            detailType = eDosageMenu
            isRowAlreadySelected = false
            tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
        } else {
            
            tableView.beginUpdates()
            let sectionCount = tableView.numberOfSections
            //tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            if (sectionCount == INITIAL_SECTION_COUNT) {
                //if section count is zero insert new section with animation
                tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            } else {
                //other wise reload the same section
                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            }
            tableView.endUpdates()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
