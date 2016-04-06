//
//  DCPodStatusSelectionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 04/04/16.
//
//

import UIKit

let podStatusArray = [PATIENT_OWN_DRUG,PATIENT_OWN_DRUG_HOME,PATIENT_OWN_AND_HOME]

typealias PODStatusUpdated = (DCMedicationScheduleDetails) -> Void

class DCPodStatusSelectionViewController: UIViewController {

    var medicationList : NSMutableArray = []
    var index : Int?
    var selectedIndexPath : NSIndexPath?
    var alertMessage : String = EMPTY_STRING
    var podStatusUpdated : PODStatusUpdated = { value in }
    
    @IBOutlet weak var updatePodStatusTableView: UITableView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureNavigationBarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        // Configure bar buttons for Add and Resolve Intervention.
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = medicationList[index!].name
        self.title = medicationList[index!].name
    }

    // MARK: - Table view methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == SectionCount.eZerothSection.rawValue {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == SectionCount.eFirstSection.rawValue {
            return 90
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        //Set the header as PREVIEW
        if section == 0 {
            if (alertMessage != EMPTY_STRING) {
                return alertMessage
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        //Change text color to red and change text from full upper case to desired sentence.
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.font = UIFont.systemFontOfSize(14.0)
            view.textLabel?.textColor = UIColor.redColor()
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
        
        alertMessage = ""
        if indexPath.section == SectionCount.eZerothSection.rawValue {
            selectedIndexPath = indexPath
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func cancelButtonPressed() {
        
        self.presentNextMedication()
    }
    
    func doneButtonPressed() {
        
        if selectedIndexPath != nil {
            if let textViewCell : DCInterventionAddResolveTextViewCell = updatePodStatusTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                if (textViewCell.reasonOrResolveTextView.text != NOTES && textViewCell.reasonOrResolveTextView.text != "" && textViewCell.reasonOrResolveTextView.text != nil) && selectedIndexPath != nil {
                    //Add to reason
                    let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[index!] as! DCMedicationScheduleDetails
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
                    medicationSheduleDetails.pharmacistAction.podStatus.notes = textViewCell.reasonOrResolveTextView.text
                    self.presentNextMedication()
                } else {
                    textViewCell.reasonOrResolveTextView.textColor = UIColor.redColor()
                }
            }
        } else {
            alertMessage =  NSLocalizedString("SELECT_POD_STATUS", comment: "title")
            updatePodStatusTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            updatePodStatusTableView.footerViewForSection(0)?.textLabel?.text = alertMessage as String
        }
    }
    
    func presentNextMedication () {
        
        self.podStatusUpdated(medicationList[index!] as! DCMedicationScheduleDetails)
        index!++
        if index < medicationList.count {
            self.dismissViewControllerAnimated(true, completion: {() -> Void in
                let updatePodStatusViewController : DCPodStatusSelectionViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(UPDATE_POD_STATUS_SB_ID) as? DCPodStatusSelectionViewController
                    updatePodStatusViewController?.medicationList = self.medicationList
                updatePodStatusViewController!.index = self.index!
                updatePodStatusViewController?.podStatusUpdated = { value in
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
}
