//
//  DCInterventionAddOrResolveViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 30/03/16.
//
//

import UIKit

typealias InterventionUpdated = (DCMedicationScheduleDetails) -> Void
typealias CancelButtonClicked = (Bool) -> Void

class DCInterventionAddOrResolveViewController: DCBaseViewController, UITableViewDataSource, UITableViewDelegate {

    var interventionType : InterventionType?
    var medicationList : NSMutableArray = []
    var indexOfCurrentMedication : Int?
    var interventionUpdated: InterventionUpdated = { value in }
    var saveButton: UIBarButtonItem =  UIBarButtonItem()
    var cancelClicked : CancelButtonClicked = { value in }

    @IBOutlet weak var interventionDisplayTableView: UITableView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.interventionDisplayTableView.keyboardDismissMode = .OnDrag
        self.interventionDisplayTableView.estimatedRowHeight = CGFloat(NORMAL_CELL_HEIGHT)
        self.interventionDisplayTableView.rowHeight = UITableViewAutomaticDimension
        self.configureNavigationBarItems()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        // Configure bar buttons for Add and Resolve Intervention.
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: #selector(DCInterventionAddOrResolveViewController.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton
        saveButton = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: #selector(DCInterventionAddOrResolveViewController.doneButtonPressed))
        self.configurSaveButton(false)
        self.navigationItem.rightBarButtonItem = saveButton
        let interventionTypeString : String
        if interventionType == eAddIntervention {
            interventionTypeString = ADD_INTERVENTION
        } else if interventionType == eEditIntervention {
            interventionTypeString =  EDIT_INTERVENTION
        } else {
            interventionTypeString = RESOLVE_INTERVENTION
        }
        self.navigationItem.title = interventionTypeString
        self.title = interventionTypeString
    }
    
    func configurSaveButton (active : Bool) {
        
        saveButton.enabled = active
    }
    
    //MARK: Tableview Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if interventionType == eAddIntervention || interventionType == eEditIntervention {
            return SectionCount.eSecondSection.rawValue
        } else {
            return SectionCount.eFourthSection.rawValue
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RowCount.eFirstRow.rawValue
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SectionCount.eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        default:
            if interventionType == eResolveIntervention {
                if indexPath.section == SectionCount.eThirdSection.rawValue {
                    return CGFloat(NORMAL_CELL_HEIGHT)
                } else {
                    return CGFloat(TEXT_VIEW_CELL_HEIGHT)
                }
            } else {
                return CGFloat(TEXT_VIEW_CELL_HEIGHT)
            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == SectionCount.eZerothSection.rawValue{
            return medicationDetailsCellInTableViewAtIndexPath(tableView,indexPath: indexPath)
        }
        switch (interventionType!.rawValue) {
        case eAddIntervention.rawValue:
            let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            cell!.placeHolderString = REASON_TEXT
            cell?.textViewUpdated = { value in
                self.configurSaveButton(value)
            }
            cell?.initializeTextView()
            if indexOfCurrentMedication != 0 {
                cell?.reasonOrResolveTextView.becomeFirstResponder()
            }
            return cell!
        case eResolveIntervention.rawValue:
            if indexPath.section == eFirstSection.rawValue {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_CELL) as? DCInterventionAddOrResolveTableCell
                return cell!
            } else if indexPath.section == eSecondSection.rawValue {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
                cell!.placeHolderString = REASON_TEXT
                cell?.textViewUpdated = { value in
                    self.configurSaveButton(value)
                }
                cell?.initializeTextView()
                if indexOfCurrentMedication != 0 {
                    cell?.reasonOrResolveTextView.becomeFirstResponder()
                }
                return cell!
            } else {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(HISTORY_OPTION_DISPLAY_CELL) as? DCInterventionAddOrResolveTableCell
                return cell!

            }
        case eEditIntervention.rawValue:
            let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[indexOfCurrentMedication!] as! DCMedicationScheduleDetails
            cell!.placeHolderString = REASON_TEXT
            cell?.initializeTextView()
            cell!.reasonOrResolveTextView.text = medicationSheduleDetails.pharmacistAction.intervention.reason
            cell?.textViewUpdated = { value in
                self.configurSaveButton(value)
            }
            cell?.reasonOrResolveTextView.becomeFirstResponder()
            return cell!

        default:
            let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == SectionCount.eThirdSection.rawValue {
            
            self.displayInterventionDetailsScreen()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func displayInterventionDetailsScreen() {
        
        let interventionDetailsViewController = UIStoryboard(name: SUMMARY_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_DETAILS_SB_ID) as? DCInterventionDetailsViewController
        self.navigationController?.pushViewController(interventionDetailsViewController!, animated: true)
    }

    func cancelButtonPressed() {
        
        self.cancelClicked(true)
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
    
        if interventionType == eAddIntervention || interventionType == eEditIntervention{
            if let textViewCell : DCInterventionAddResolveTextViewCell = interventionDisplayTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                if textViewCell.reasonOrResolveTextView.text != REASON_TEXT && textViewCell.reasonOrResolveTextView.text != EMPTY_STRING && textViewCell.reasonOrResolveTextView.text != nil {
                    //Add to reason
                    let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[indexOfCurrentMedication!] as! DCMedicationScheduleDetails
                    //TODO: Add the details
                    //Save name of the pharmacist who created the intervention.
                    medicationSheduleDetails.pharmacistAction.intervention.createdBy = EMPTY_STRING
                    //Save the time at which the intervention is created.
                    medicationSheduleDetails.pharmacistAction.intervention.createdOn = EMPTY_STRING
                    medicationSheduleDetails.pharmacistAction.intervention.reason = textViewCell.reasonOrResolveTextView.text
                    medicationSheduleDetails.pharmacistAction.intervention.toResolve = true
                    self.presentNextMedication()
                } else {
                    textViewCell.reasonOrResolveTextView.textColor = UIColor.redColor()
                }
            }
        } else {
            if let textViewCell : DCInterventionAddResolveTextViewCell = interventionDisplayTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eSecondSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                if textViewCell.reasonOrResolveTextView.text != RESOLUTION_TEXT && textViewCell.reasonOrResolveTextView.text != EMPTY_STRING && textViewCell.reasonOrResolveTextView.text != nil {
                    let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[indexOfCurrentMedication!] as! DCMedicationScheduleDetails
                    medicationSheduleDetails.pharmacistAction.intervention.resolution = textViewCell.reasonOrResolveTextView.text
                    medicationSheduleDetails.pharmacistAction.intervention.toResolve = false
                    self.presentNextMedication()
                } else {
                    textViewCell.reasonOrResolveTextView.textColor = UIColor.redColor()
                }
            }
        }
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
    
    func presentNextMedication () {
        
        //Present view with next medication, if in case of multiple selection.
        //Clousure "interventionUpdated" is called to pass data back to parent.
        self.interventionUpdated(self.medicationList[self.indexOfCurrentMedication!] as! DCMedicationScheduleDetails)
        indexOfCurrentMedication! += 1
        if indexOfCurrentMedication < medicationList.count {
            //In case of multiple selections, the present view is dismissed and new view is loaded with details of next medication.
            self.dismissViewControllerAnimated(true, completion: {() -> Void in
                //New view is presented in the completion block of dismiss
                let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
                addInterventionViewController!.indexOfCurrentMedication = self.indexOfCurrentMedication!
                addInterventionViewController?.medicationList = self.medicationList
                addInterventionViewController?.interventionType = self.interventionType
                addInterventionViewController!.interventionUpdated = { value in
                    //Recursive call is done to pass data to parent.
                    self.interventionUpdated(value)
                }
                addInterventionViewController?.cancelClicked = { value in
                    self.cancelClicked(value)
                }
                let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
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
                self.interventionDisplayTableView.contentInset = contentInsets;
                self.interventionDisplayTableView.scrollIndicatorInsets = contentInsets;
                var lastIndexPath : NSIndexPath
                if interventionType == eResolveIntervention {
                    lastIndexPath = NSIndexPath(forRow: 0, inSection: interventionDisplayTableView.numberOfSections-2 )
                } else {
                    lastIndexPath = NSIndexPath(forRow: 0, inSection: interventionDisplayTableView.numberOfSections-1 )
                }
                self.interventionDisplayTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsMake(0, 0, 0, 0);
        interventionDisplayTableView.contentInset = contentInsets;
        interventionDisplayTableView.scrollIndicatorInsets = contentInsets;
        interventionDisplayTableView.beginUpdates()
        interventionDisplayTableView.endUpdates()
    }
}
