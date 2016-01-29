//
//  AdministrationTimesViewController.swift
//  DrugChart
//
//  Created by qbuser on 1/29/16.
//
//

import UIKit

protocol AdministrationTimesDelegate {
    
    func updatedAdministrationTimeArray(timeArray : NSArray)
}

class DCAdministrationTimesViewController: UITableViewController {
    
    var timeArray : NSMutableArray = []
    var delegate : AdministrationTimesDelegate?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("ADMINISTRATING_TIME", comment: "")
        if timeArray.count == 0 {
            timeArray = NSMutableArray(array: DCPlistManager.administratingTimeList())
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(true)
        if let administrationTimeDelegate = delegate {
            administrationTimeDelegate.updatedAdministrationTimeArray(timeArray)
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private Methods
        
    func displayAddNewTimeScreen() {
        
        let addNewTimeViewController : DCAddNewDoseAndTimeViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_NEW_DOSE_TIME_SBID) as? DCAddNewDoseAndTimeViewController
        addNewTimeViewController?.detailType = eAddNewTimes
        addNewTimeViewController!.newDosageEntered = { value in
            self.refreshViewWithNewAdministrationTime(value!)
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: addNewTimeViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func refreshViewWithNewAdministrationTime(newTime : String) {
        
        let timeDictionary = [TIME_KEY : newTime, SELECTED_KEY : 1]
        var previousTimeArray = NSMutableArray(array: timeArray)
        var timeAlreadyAdded = false
        var alreadyAddedSlotTag = 0
        for contentDictionary in previousTimeArray {
            let content = contentDictionary[TIME_KEY] as! String
            let time = timeDictionary[TIME_KEY] as! String
            if(content == time) {
                timeAlreadyAdded = true
                alreadyAddedSlotTag = timeArray.indexOfObject(contentDictionary)
                break
            }
        }
        if timeAlreadyAdded == true {
            previousTimeArray.replaceObjectAtIndex(alreadyAddedSlotTag, withObject: timeDictionary)
        } else {
            previousTimeArray.addObject(timeDictionary)
        }
        previousTimeArray = NSMutableArray(array: DCUtility.sortArray(previousTimeArray as [AnyObject], basedOnKey: TIME_KEY, ascending: true))
        timeArray = NSMutableArray(array: previousTimeArray)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SectionCount.eSecondSection.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (section == SectionCount.eZerothSection.rawValue) ? timeArray.count : RowCount.eFirstRow.rawValue
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ADMINISTRATION_TIMES_CELLID, forIndexPath: indexPath)
        cell.textLabel!.font = UIFont.systemFontOfSize(15.0)
        if indexPath.section == SectionCount.eZerothSection.rawValue {
            let timeDictionary = timeArray.objectAtIndex(indexPath.row) as! NSDictionary
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.text = timeDictionary.valueForKey(TIME_KEY) as? String
            let selectedStatus = timeDictionary.valueForKey(SELECTED_KEY) as? NSInteger
            cell.accessoryType = (selectedStatus == 1) ? .Checkmark : .None
        } else {
            cell.textLabel?.textColor = tableView.tintColor
            cell.textLabel?.text = NSLocalizedString("ADD_TIME", comment: "")
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let contentDictionary = timeArray.objectAtIndex(indexPath.row) as! NSDictionary
            var selectedStatus = contentDictionary[SELECTED_KEY] as! NSInteger
            let time = contentDictionary[TIME_KEY]
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if selectedStatus == 1 {
                selectedStatus = 0
                cell?.accessoryType = .None
            } else {
                selectedStatus = 1
                cell?.accessoryType = .Checkmark
            }
            let updatedDictionary = [TIME_KEY : time!, SELECTED_KEY : NSNumber(integer: selectedStatus)] as NSDictionary
            timeArray.replaceObjectAtIndex(indexPath.row, withObject: updatedDictionary)
        } else {
            displayAddNewTimeScreen()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
