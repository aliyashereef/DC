//
//  DCPodStatusSelectionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 04/04/16.
//
//

import UIKit

let podStatusArray = [PATIENT_OWN_DRUG,PATIENT_OWN_DRUG_HOME,PATIENT_OWN_AND_HOME,NONE_TEXT]

typealias PODStatusUpdated = (DCMedicationScheduleDetails) -> Void

class DCPodStatusSelectionViewController: DCBaseViewController {

    var medicationList : NSMutableArray = []
    var indexOfCurrentMedication : Int?
    var selectedIndexPath : NSIndexPath?
    var podStatusUpdated : PODStatusUpdated = { value in }
    var doneButton = UIBarButtonItem?()
    let tableviewContentOffset = 30
    var cancelClicked : CancelButtonClicked = { value in }
    
    @IBOutlet weak var updatePodStatusTableView: UITableView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureNavigationBarItems()
        self.updatePodStatusTableView.keyboardDismissMode = .OnDrag
        updatePodStatusTableView.estimatedRowHeight = CGFloat(NORMAL_CELL_HEIGHT)
        updatePodStatusTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        updatePodStatusTableView.reloadData()
    }
    
    func configureNavigationBarItems() {
        
        // Configure bar buttons for Add and Resolve Intervention.
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: #selector(DCPodStatusSelectionViewController.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton
        doneButton = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: #selector(DCPodStatusSelectionViewController.doneButtonPressed))
        doneButton?.enabled = false
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = UPDATE_POD_STATUS
        self.title = UPDATE_POD_STATUS
    }

    // MARK: - Table view methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return SectionCount.eThirdSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == SectionCount.eFirstSection.rawValue {
            return podStatusArray.count
        } else {
            return RowCount.eFirstRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == SectionCount.eSecondSection.rawValue {
            return CGFloat(TEXT_VIEW_CELL_HEIGHT)
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case SectionCount.eZerothSection.rawValue:
            return medicationDetailsCellInTableViewAtIndexPath(tableView, indexPath: indexPath)
        case SectionCount.eFirstSection.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(POD_STATUS_CELL) as? DCPodStatusTableViewCell
            cell?.podStatusLabel.text = podStatusArray[indexPath.row]
            if (selectedIndexPath != nil && selectedIndexPath == indexPath) {
                cell?.accessoryType = .Checkmark
            } else {
                cell?.accessoryType = .None
            }
            return cell!
        case SectionCount.eSecondSection.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(POD_NOTES_CELL_ID) as? DCInterventionAddResolveTextViewCell
                cell!.placeHolderString = NOTES
                cell?.initializeTextView()
                return cell!
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        doneButton?.enabled = true
        if indexPath.section == SectionCount.eFirstSection.rawValue {
            selectedIndexPath = indexPath
            tableView.reloadSections(NSIndexSet(index:indexPath.section ), withRowAnimation: .None)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //Medication Details Cell
    func medicationDetailsCellInTableViewAtIndexPath (tableView : UITableView,indexPath :NSIndexPath) -> UITableViewCell {
        let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[indexOfCurrentMedication!] as! DCMedicationScheduleDetails
        if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationSheduleDetails){
            let cell = tableView.dequeueReusableCellWithIdentifier(StopMedicationConstants.DURATION_BASED_INFUSION_CELL) as? DCDurationBasedMedicationDetailsCell
            cell!.configureMedicationDetails(medicationSheduleDetails)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(StopMedicationConstants.MEDICATION_DETAILS_CELL) as? DCMedicationDetailsTableViewCell
            cell!.configureMedicationDetails(medicationSheduleDetails)
            return cell!
        }
    }
    
    func cancelButtonPressed() {
        
        self.cancelClicked(true)
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
        
        if selectedIndexPath != nil {
            let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[indexOfCurrentMedication!] as! DCMedicationScheduleDetails
            switch (selectedIndexPath!.row) {
            case RowCount.eZerothRow.rawValue:
                medicationSheduleDetails.pharmacistAction.podStatus.podStatusType = ePatientOwnDrugs
            case RowCount.eFirstRow.rawValue:
                medicationSheduleDetails.pharmacistAction.podStatus.podStatusType = ePatientOwnDrugsHome
            case RowCount.eSecondRow.rawValue:
                medicationSheduleDetails.pharmacistAction.podStatus.podStatusType = ePatientOwnDrugsAndPatientOwnDrugsHome
            default:
                break
            }
            if let textViewCell : DCInterventionAddResolveTextViewCell = updatePodStatusTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                if (textViewCell.reasonOrResolveTextView.text != NOTES && textViewCell.reasonOrResolveTextView.text != EMPTY_STRING && textViewCell.reasonOrResolveTextView.text != nil) && selectedIndexPath != nil {
                    //Add to reason
                    medicationSheduleDetails.pharmacistAction.podStatus.notes = textViewCell.reasonOrResolveTextView.text
                }
            }
            self.presentNextMedication()
        }
    }
    
    func presentNextMedication () {
        
        //Present view with next medication, if in case of multiple selection.
        //Clousure "interventionUpdated" is called to pass data back to parent.
        self.podStatusUpdated(medicationList[indexOfCurrentMedication!] as! DCMedicationScheduleDetails)
        indexOfCurrentMedication! += 1
        if indexOfCurrentMedication < medicationList.count {
            //In case of multiple selections, the present view is dismissed and new view is loaded with details of next medication.
            self.dismissViewControllerAnimated(true, completion: {() -> Void in
                //New view is presented in the completion block of dismiss
                let updatePodStatusViewController : DCPodStatusSelectionViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(UPDATE_POD_STATUS_SB_ID) as? DCPodStatusSelectionViewController
                    updatePodStatusViewController?.medicationList = self.medicationList
                updatePodStatusViewController!.indexOfCurrentMedication = self.indexOfCurrentMedication!
                updatePodStatusViewController?.podStatusUpdated = { value in
                    //Recursive call is done to pass data to parent.
                    self.podStatusUpdated(value)
                }
                updatePodStatusViewController?.cancelClicked = { value in
                    self.cancelClicked(value)
                }
                let navigationController: UINavigationController = UINavigationController(rootViewController: updatePodStatusViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(navigationController, animated: true, completion: { _ in })
            })
        } else {
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: Notification Methods
    func keyboardDidShow(notification : NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let contentInsets: UIEdgeInsets
                contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0)
                self.updatePodStatusTableView.contentInset = contentInsets;
                self.updatePodStatusTableView.scrollIndicatorInsets = contentInsets;
                let lastIndexPath = NSIndexPath(forRow: 0, inSection: updatePodStatusTableView.numberOfSections-1 )
                self.updatePodStatusTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsMake(40, 0, 0, 0);
        updatePodStatusTableView.contentInset = contentInsets;
        updatePodStatusTableView.scrollIndicatorInsets = contentInsets;
        updatePodStatusTableView.beginUpdates()
        updatePodStatusTableView.endUpdates()
    }
}
