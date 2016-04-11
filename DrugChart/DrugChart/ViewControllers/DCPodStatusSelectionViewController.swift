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
    
    @IBOutlet weak var updatePodStatusTableView: UITableView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureNavigationBarItems()
        self.updatePodStatusTableView.keyboardDismissMode = .OnDrag
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        // Configure bar buttons for Add and Resolve Intervention.
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
        doneButton = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
        doneButton?.enabled = false
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = medicationList[indexOfCurrentMedication!].name
        self.title = medicationList[indexOfCurrentMedication!].name
    }

    // MARK: - Table view methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return SectionCount.eSecondSection.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == SectionCount.eZerothSection.rawValue {
            return podStatusArray.count
        } else {
            return RowCount.eFirstRow.rawValue
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == SectionCount.eFirstSection.rawValue {
            return CGFloat(TEXT_VIEW_CELL_HEIGHT)
        } else {
            return CGFloat(NORMAL_CELL_HEIGHT)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case SectionCount.eZerothSection.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(POD_STATUS_CELL) as? DCPodStatusTableViewCell
            cell?.podStatusLabel.text = podStatusArray[indexPath.row]
            if (selectedIndexPath != nil && selectedIndexPath == indexPath) {
                cell?.accessoryType = .Checkmark
            } else {
                cell?.accessoryType = .None
            }
            return cell!
        case SectionCount.eFirstSection.rawValue:
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
        if indexPath.section == SectionCount.eZerothSection.rawValue {
            selectedIndexPath = indexPath
            tableView.reloadSections(NSIndexSet(index: RowCount.eZerothRow.rawValue), withRowAnimation: .None)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func cancelButtonPressed() {
        
        self.presentNextMedication()
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
        indexOfCurrentMedication!++
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
                let navigationController: UINavigationController = UINavigationController(rootViewController: updatePodStatusViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(navigationController, animated: true, completion: { _ in })
            })
        } else {
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func keyboardDidShow(notification : NSNotification) {
        
        self.updatePodStatusTableView.contentOffset = CGPoint(x: 0, y: tableviewContentOffset)
    }
    
    func keyboardDidHide(notification :NSNotification){
        
        updatePodStatusTableView.contentOffset = CGPoint(x: 0, y: -tableviewContentOffset);
    }

}
