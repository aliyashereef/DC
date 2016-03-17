//
//  DCMedicationSummaryDisplayViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 08/03/16.
//
//

import UIKit

class DCMedicationSummaryDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var medicationSlotsArray : [DCMedicationSlot] = [DCMedicationSlot]()
    var medicationDetails : DCMedicationScheduleDetails?
    var contentArray :[AnyObject] = []
    var slotToAdminister : DCMedicationSlot?
    var weekDate : NSDate?
    @IBOutlet var summaryDisplayTableView: UITableView!
    var patientId : NSString = EMPTY_STRING
    var scheduleId : NSString = EMPTY_STRING
    var errorMessage : String = EMPTY_STRING
    var helper : DCSwiftObjCNavigationHelper = DCSwiftObjCNavigationHelper.init()
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureTableViewProperties()
        self.configureNavigationBar()
    }
    
    func configureTableViewProperties (){
        self.summaryDisplayTableView.rowHeight = UITableViewAutomaticDimension
        self.summaryDisplayTableView.estimatedRowHeight = 44.0
        self.summaryDisplayTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func configureNavigationBar() {
        //Navigation bar title string
        self.title = "Medication Details"
        // Navigation bar done button
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonPressed")
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
            self.navigationItem.rightBarButtonItems = [doneButton]
        } else {
            let negativeSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            negativeSpacer.width = -12
            self.navigationItem.rightBarButtonItems = [negativeSpacer,doneButton]
        }
    }
    
    func configureMedicationStatusInCell (medication : DCMedicationSlot) -> NSString {
        
        let currentSystemDate : NSDate = NSDate()
        let currentDateString : NSString? = DCDateUtility.dateStringFromDate(currentSystemDate, inFormat: SHORT_DATE_FORMAT)
        
        if (medication.medicationAdministration?.status != nil && medication.medicationAdministration.actualAdministrationTime != nil){
            if medication.medicationAdministration?.status == REFUSED {
                return NOT_ADMINISTRATED
            } else {
                return (medication.medicationAdministration?.status)!
            }
        }
        if medication.medicationAdministration?.status == STARTED {
            return IN_PROGRESS
        }
        //medication slot selected more than the current date
        if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedDescending){
            let slotDateString : NSString? = DCDateUtility.dateStringFromDate(slotToAdminister?.time, inFormat: SHORT_DATE_FORMAT)
            if (currentDateString != slotDateString && medication.medicationAdministration?.status == nil) {
                return PENDING
            } else if (medication.medicationAdministration?.status != nil) {
                if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!) {
                    return IN_PROGRESS
                } else {
                    return medication.medicationAdministration.status
                }
            }
        }
        if let slotToAdministerDate = slotToAdminister?.time {
            if (medication.time.compare(slotToAdministerDate) == NSComparisonResult.OrderedSame) {
                return ADMINISTER_MEDICATION
            }
        }
        //medication slot selected less than the current date
        if (medication.time.compare(currentSystemDate) == NSComparisonResult.OrderedAscending) {
            if (medication.medicationAdministration?.status != nil) {
                if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!) {
                    return IN_PROGRESS
                } else {
                    return medication.medicationAdministration.status
                }
            } else if (slotToAdminister?.medicationAdministration?.actualAdministrationTime == nil){
                return PENDING
            }
        }
        return PENDING
    }
    
    //MARK: TableView Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 1
        case 1 : return 2
        default : break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0 :
            return configureMedicationDetailsCellAtIndexPath(indexPath)
        default:
            return configureContentCellAtIndexPath(indexPath)
        }
    }
    
    func configureMedicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        let cell = summaryDisplayTableView.dequeueReusableCellWithIdentifier("summaryDisplayHeaderCell") as? DCMedicationSummaryDisplayHeaderTableViewCell
        if let _ = medicationDetails {
            cell!.configureMedicationDetails(medicationDetails!)
        }
        return cell!
    }
    
    func configureContentCellAtIndexPath (indexPath :NSIndexPath) -> DCMedicationSummaryDisplayTableViewCell{
        
        let cell : DCMedicationSummaryDisplayTableViewCell = summaryDisplayTableView.dequeueReusableCellWithIdentifier("menuCell") as! DCMedicationSummaryDisplayTableViewCell
        if indexPath.row == 0 {
            cell.contentLabel.text = "Administration History"
        } else {
            cell.contentLabel.text = "Review History"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 0) {
            
        } else {
            if indexPath.row == 0 {
                let administrationHistoryViewController : DCSummaryAdministrationHistoryViewController? = UIStoryboard(name: SUMMARY_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(MEDICATION_SUMMARY_ADMINISTRATION_HISTORY_SBID) as? DCSummaryAdministrationHistoryViewController
                administrationHistoryViewController?.medicationType = DCCalendarHelper.typeDescriptionForMedication(medicationDetails!)
                self.navigationController?.pushViewController(administrationHistoryViewController!, animated: true)
            } else {
                let summaryHistoryViewController : DCSummaryReviewHistoryDisplayViewController? = UIStoryboard(name: SUMMARY_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(MEDICATION_SUMMARY_REVIEW_HISTORY_SBID) as? DCSummaryReviewHistoryDisplayViewController
                self.navigationController?.pushViewController(summaryHistoryViewController!, animated: true)
            }
        }
    }
    
    func doneButtonPressed() {
        
        slotToAdminister = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }    
}
