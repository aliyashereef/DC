//
//  DCManageSuspensionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 09/05/16.
//
//

import UIKit

class DCManageSuspensionViewController: DCBaseViewController, UITableViewDataSource, UITableViewDelegate {

    var medicationDetails : DCMedicationScheduleDetails?
    var saveButton = UIBarButtonItem?()
    var saveButtonClicked :Bool = false
    var isFromEntryValid : Bool = false
    var isUntilEntryValid : Bool = false
    var isInEditMode : Bool = false
    var isReasonEntryValid : Bool = false
    let tableviewContentOffset = 110

    @IBOutlet weak var manageSuspensionTableview: UITableView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.configureNavigationBarItems()
        if medicationDetails?.manageSuspension == nil {
            medicationDetails?.manageSuspension = DCManageSuspensionDetails.init()
        } else {
            isInEditMode = true
        }
        self.manageSuspensionTableview.keyboardDismissMode = .OnDrag
        self.manageSuspensionTableview.rowHeight = UITableViewAutomaticDimension
        self.manageSuspensionTableview.estimatedRowHeight = CGFloat(NORMAL_CELL_HEIGHT)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.manageSuspensionTableview.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        // Configure bar buttons for Add and Resolve Intervention.
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: #selector(DCManageSuspensionViewController.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton
        saveButton = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: #selector(DCManageSuspensionViewController.doneButtonPressed))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.title = MANAGE_SUSPENSION_TITLE
        self.title = MANAGE_SUSPENSION_TITLE
    }

    // MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SectionCount.eFourthSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SectionCount.eZerothSection.rawValue:
            return RowCount.eFirstRow.rawValue
        case SectionCount.eFirstSection.rawValue:
            return RowCount.eSecondRow.rawValue
        case SectionCount.eSecondSection.rawValue:
            return RowCount.eFirstRow.rawValue
        case SectionCount.eThirdSection.rawValue:
            return RowCount.eFirstRow.rawValue
        default:
            return RowCount.eZerothRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch(indexPath.section) {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        case SectionCount.eThirdSection.rawValue:
            return CGFloat(TEXT_VIEW_CELL_HEIGHT)
        default:
            return CGFloat(NORMAL_CELL_HEIGHT)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let displayCell = self.confugureCellForDisplay(indexPath)
        return displayCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.actionForCellSelectedAtIndexPath(indexPath)
    }
    
    func confugureCellForDisplay(indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : DCManageSuspensionTableViewCell = manageSuspensionTableview.dequeueReusableCellWithIdentifier(MANAGE_SUSPENSION_CELL) as! DCManageSuspensionTableViewCell
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return self.medicationDetailsCellAtIndexPath(indexPath)
        case SectionCount.eFirstSection.rawValue:
            if indexPath.row == RowCount.eZerothRow.rawValue {
                cell.titleLabel.text = DOSE_FROM_TITLE
                if saveButtonClicked {
                    if !isFromEntryValid {
                        cell.titleLabel.textColor = UIColor.redColor()
                    } else {
                        cell.titleLabel.textColor = UIColor.blackColor()
                    }
                }
                if medicationDetails?.manageSuspension.manageSuspensionFromType == nil || medicationDetails?.manageSuspension.manageSuspensionFromType == EMPTY_STRING {
                    cell.detailLabel.text = EMPTY_STRING
                } else if medicationDetails?.manageSuspension.manageSuspensionFromType == SUSPEND_IMMEDIATELY {
                    cell.detailLabel.text = medicationDetails?.manageSuspension.manageSuspensionFromType
                } else if medicationDetails!.manageSuspension.manageSuspensionFromType == SUSPEND_FROM {
                    if medicationDetails!.manageSuspension.fromDate != nil {
                        cell.detailLabel.text = "\(medicationDetails!.manageSuspension.manageSuspensionFromType) \(medicationDetails!.manageSuspension.fromDate)"
                    } else {
                        cell.detailLabel.text = EMPTY_STRING
                    }
                }
            } else {
                cell.titleLabel.text = UNTIL_TITLE
                if saveButtonClicked {
                    if !isUntilEntryValid {
                        cell.titleLabel.textColor = UIColor.redColor()
                    } else {
                        cell.titleLabel.textColor = UIColor.blackColor()
                    }
                }
                if medicationDetails?.manageSuspension.manageSuspensionUntilType == nil || medicationDetails?.manageSuspension.manageSuspensionUntilType == EMPTY_STRING {
                    cell.detailLabel.text = EMPTY_STRING
                } else if medicationDetails?.manageSuspension.manageSuspensionUntilType == MANUALLY_UNSUSPENDED {
                    cell.detailLabel.text = medicationDetails?.manageSuspension.manageSuspensionUntilType
                } else if medicationDetails?.manageSuspension.manageSuspensionUntilType == SPECIFIED_DATE {
                    if medicationDetails!.manageSuspension.specifiedUntilDate != nil {
                        cell.detailLabel.text = "Until \(medicationDetails!.manageSuspension.specifiedUntilDate)"
                    } else {
                        cell.detailLabel.text = EMPTY_STRING
                    }
                } else {
                    if medicationDetails!.manageSuspension.specifiedDose != nil {
                        cell.detailLabel.text = "Until Dose \(medicationDetails!.manageSuspension.specifiedDose)"
                    } else {
                        cell.detailLabel.text = EMPTY_STRING
                    }
                }
            }
        case SectionCount.eSecondSection.rawValue:
            cell.titleLabel.text = REASON
            if saveButtonClicked {
                if !isReasonEntryValid {
                    cell.titleLabel.textColor = UIColor.redColor()
                } else {
                    cell.titleLabel.textColor = UIColor.blackColor()
                }
            }
            cell.detailLabel.text = medicationDetails?.manageSuspension.reason
        case SectionCount.eThirdSection.rawValue:
            let cell = manageSuspensionTableview.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            cell!.placeHolderString = NOTES
            cell?.initializeTextView()
            if medicationDetails?.manageSuspension.notes != nil && medicationDetails?.manageSuspension.notes != EMPTY_STRING {
                cell?.reasonOrResolveTextView.text = medicationDetails?.manageSuspension.notes
            }
            if self.validateManageSuspensionReason() && medicationDetails?.manageSuspension.reason == OTHER_TEXT && ( medicationDetails?.manageSuspension.notes == nil || medicationDetails?.manageSuspension.notes == EMPTY_STRING ){
                cell?.reasonOrResolveTextView.textColor = UIColor.redColor()
            }
            cell?.textViewUpdated = { value in
                //TODO: Save the entered notes.
            }
            cell?.textViewValueEntered = { value in
             
                self.medicationDetails?.manageSuspension.notes = value
            }
            return cell!
        default:
            break
        }
        return cell
    }
    
    //Medication Details Cell
    func medicationDetailsCellAtIndexPath (indexPath :NSIndexPath) -> UITableViewCell {
        
        if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails!){
            let cell = self.manageSuspensionTableview.dequeueReusableCellWithIdentifier(StopMedicationConstants.DURATION_BASED_INFUSION_CELL) as? DCDurationBasedMedicationDetailsCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            cell?.accessoryType = .None
            return cell!
        } else {
            let cell = self.manageSuspensionTableview.dequeueReusableCellWithIdentifier(StopMedicationConstants.MEDICATION_DETAILS_CELL) as? DCMedicationDetailsTableViewCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            cell?.accessoryType = .None
            return cell!
        }
    }
    
    func actionForCellSelectedAtIndexPath(indexPath : NSIndexPath) {
        
        switch indexPath.section {
        case SectionCount.eFirstSection.rawValue:
            self.presentManageSuspensionFromAndUntilView(indexPath)
        case SectionCount.eSecondSection.rawValue:
            self.presentReasonScreen(indexPath)
        default:
            break
        }
    }
    
    func presentManageSuspensionFromAndUntilView(indexPath : NSIndexPath) {
        
        if indexPath.row == RowCount.eZerothRow.rawValue {
            let manageSuspensionFromViewController : DCManageSuspensionFromViewController? = UIStoryboard(name: PRESCRIBER_DETAILS_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(MANAGE_SUSPENSION_FROM_VC_SB_ID) as? DCManageSuspensionFromViewController
            manageSuspensionFromViewController?.manageSuspensionDetails = medicationDetails?.manageSuspension
            manageSuspensionFromViewController?.saveButtonClicked = saveButtonClicked
            manageSuspensionFromViewController?.manageSuspensionUpdated = { value in
             
                self.isFromEntryValid = self.validateManageSuspensionFromOption()
            }
            self.navigationController!.pushViewController(manageSuspensionFromViewController!, animated: true)
        } else {
            let manageSuspensionUntilViewController : DCManageSuspensionUntilViewController? = UIStoryboard(name: PRESCRIBER_DETAILS_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(MANAGE_SUSPENSION_UNTIL_VC_SB_ID) as? DCManageSuspensionUntilViewController
            manageSuspensionUntilViewController?.manageSuspensionDetails = medicationDetails?.manageSuspension
            manageSuspensionUntilViewController?.saveButtonClicked = saveButtonClicked
            manageSuspensionUntilViewController?.manageSuspensionUpdated = { value in
             
                self.isUntilEntryValid = self.validateManageSuspensionUntilOption()
            }
            self.navigationController?.pushViewController(manageSuspensionUntilViewController!, animated: true)
        }
    }
    
    func presentReasonScreen(indexPath : NSIndexPath) {
        
        let manageSuspensionReasonViewController : DCManageSuspensionReasonViewController? = UIStoryboard(name: PRESCRIBER_DETAILS_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(MANAGE_SUSPENSION_REASON_SB_ID) as? DCManageSuspensionReasonViewController
        manageSuspensionReasonViewController?.manageSuspensionDetails = medicationDetails?.manageSuspension
        manageSuspensionReasonViewController?.manageSuspensionUpdated = { value in
         
            self.isReasonEntryValid = self.validateManageSuspensionReason()
            self.manageSuspensionTableview.reloadData()
        }
        self.navigationController!.pushViewController(manageSuspensionReasonViewController!, animated: true)
    }
    
    func validateManageSuspensionFromOption() -> Bool {
        
        if medicationDetails?.manageSuspension.manageSuspensionFromType != nil {
            if medicationDetails?.manageSuspension.manageSuspensionFromType == SUSPEND_FROM {
                if medicationDetails?.manageSuspension.fromDate == nil {
                    return false
                }
            }
        } else {
            return false
        }
        return true
    }
    
    func validateManageSuspensionUntilOption() -> Bool {
        
        if medicationDetails?.manageSuspension.manageSuspensionUntilType != nil {
            if medicationDetails?.manageSuspension.manageSuspensionUntilType == SPECIFIED_DATE {
                if medicationDetails?.manageSuspension.specifiedUntilDate == nil {
                    return false
                }
            } else if medicationDetails?.manageSuspension.manageSuspensionUntilType == SPECIFIED_DOSE {
                if medicationDetails?.manageSuspension.specifiedDose == nil {
                    return false
                }
            }
        } else {
            return false
        }
        return true
    }
    
    func validateManageSuspensionReason() -> Bool {
        
        if medicationDetails?.manageSuspension.reason == nil {
            return false
        }
        return true
    }
    
    func cancelButtonPressed() {
        
        if !isInEditMode {
            medicationDetails?.manageSuspension = nil
        }
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }

    func doneButtonPressed() {
        
        saveButtonClicked = true
        isFromEntryValid = self.validateManageSuspensionFromOption()
        isUntilEntryValid = self.validateManageSuspensionUntilOption()
        isReasonEntryValid = self.validateManageSuspensionReason()
        if medicationDetails?.manageSuspension.reason == OTHER_TEXT && (medicationDetails?.manageSuspension.notes == nil || medicationDetails?.manageSuspension.notes == EMPTY_STRING || medicationDetails?.manageSuspension.notes == NOTES) {
            // Notes not entered.
        } else {
            if isFromEntryValid && isUntilEntryValid && isReasonEntryValid {
                //TODO: Save the entered values.
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        manageSuspensionTableview.reloadData()
    }
    // MARK: - Keyboard Delegate Methods
    
    func keyboardDidShow(notification : NSNotification) {
        
        //If the no of array elements is greater than the threshold value then the view should adjust.
        if appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow {
            self.manageSuspensionTableview.contentOffset = CGPoint(x: 0, y: TEXT_VIEW_CELL_HEIGHT + 50)
        } else {
            self.manageSuspensionTableview.contentOffset = CGPoint(x: 0, y: tableviewContentOffset)
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        
        //If the no of array elements is greater than the threshold value then the view should adjust to make the new entry visible.
        if appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow {
            self.manageSuspensionTableview.contentOffset = CGPoint(x: zeroInt, y: Int(-TEXT_VIEW_CELL_HEIGHT + 50));
        } else {
            self.manageSuspensionTableview.contentOffset = CGPoint(x: zeroInt, y: Int(-36));
        }
    }
}
