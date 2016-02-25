//
//  DCAdministrationInProgressViewController.swift
//  DrugChart
//
//  Created by aliya on 25/02/16.
//
//

import Foundation

class DCAdministrationInProgressViewController : UIViewController,StatusListDelegate {
    
    @IBOutlet weak var administerInProgressTableView: UITableView!
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureTableViewProperties()
    }
    
    // MARK: Private Methods
    
    func configureTableViewProperties (){
        
        self.administerInProgressTableView.rowHeight = UITableViewAutomaticDimension
        self.administerInProgressTableView.estimatedRowHeight = 44.0
        self.administerInProgressTableView.tableFooterView = UIView(frame: CGRectZero)
        administerInProgressTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    //MARK: Configuring Table View Cells
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        let cell = administerInProgressTableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
        if let _ = medicationDetails {
            cell!.configureMedicationDetails(medicationDetails!)
        }
        return cell!
    }
    
    // Administration Status Cell
    func administrationStatusTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell) {
        
        let administerCell : DCAdministerCell = (administerInProgressTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        administerCell.titleLabel.text = STATUS
        medicationSlot?.medicationAdministration.status = IN_PROGRESS
        administerCell.detailLabel?.text = IN_PROGRESS
        return administerCell
    }

    //MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default :
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            return self.medicationDetailsCellAtIndexPath(indexPath)
        case 1:
            // cell for graph
            return self.medicationDetailsCellAtIndexPath(indexPath)

        case 2:
            return self.administrationStatusTableCellAtIndexPath(indexPath)
        default:
            return self.medicationDetailsCellAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eFirstSection.rawValue:
                return 44
        case SectionCount.eSecondSection.rawValue:
            return 44
        default:
            return 44
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        administerInProgressTableView.deselectRowAtIndexPath(indexPath, animated: true)
        administerInProgressTableView.resignFirstResponder()
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            self.navigationController?.pushViewController(DCAdministrationHelper.addBNFView(), animated: true)
            break
        case SectionCount.eSecondSection.rawValue:
            let statusViewController : DCAdministrationStatusTableViewController = DCAdministrationHelper.administratedStatusPopOverAtIndexPathWithStatus(indexPath, status:ADMINISTERED)
            statusViewController.previousSelectedValue = self.medicationSlot?.medicationAdministration?.status
            statusViewController.medicationStatusDelegate = self
            self.navigationController!.pushViewController(statusViewController, animated: true)
            break
        default:
            break
        }
    }
    
    // mark:StatusList Delegate Methods
    func selectedMedicationStatusEntry(status: String!) {
        
        let parentView : DCAdministrationStatusSelectionViewController = self.parentViewController as! DCAdministrationStatusSelectionViewController
        medicationSlot?.medicationAdministration.status = status
        parentView.updateViewWithChangeInStatus(status)
    }
    
    
}
