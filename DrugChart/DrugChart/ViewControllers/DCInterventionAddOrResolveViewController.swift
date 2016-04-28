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

class DCInterventionAddOrResolveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var interventionType : InterventionType?
    var medicationList : NSMutableArray = []
    var indexOfCurrentMedication : Int?
    var interventionUpdated: InterventionUpdated = { value in }
    var saveButton: UIBarButtonItem =  UIBarButtonItem()
    var cancelClicked : CancelButtonClicked = { value in }

    @IBOutlet weak var interventionDisplayTableView: UITableView!
    
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
        saveButton = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
        self.configurSaveButton(false)
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.title = medicationList[indexOfCurrentMedication!].name
        self.title = medicationList[indexOfCurrentMedication!].name
    }
    
    func configurSaveButton (active : Bool) {
        
        saveButton.enabled = active
    }
    
    //MARK: Tableview Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if interventionType == eAddIntervention {
            return SectionCount.eFirstSection.rawValue
        } else {
            return SectionCount.eSecondSection.rawValue
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RowCount.eFirstRow.rawValue
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return CGFloat(TEXT_VIEW_CELL_HEIGHT)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            if indexPath.section == eZerothSection.rawValue {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_CELL) as? DCInterventionAddOrResolveTableCell
                return cell!
            } else {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
                cell!.placeHolderString = RESOLUTION_TEXT
                cell?.textViewUpdated = { value in
                    self.configurSaveButton(value)
                }
                cell?.initializeTextView()
                if indexOfCurrentMedication != 0 {
                    cell?.reasonOrResolveTextView.becomeFirstResponder()
                }
                return cell!
            }
        default:
            let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func cancelButtonPressed() {
        
        self.cancelClicked(true)
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
    
        if interventionType == eAddIntervention {
            if let textViewCell : DCInterventionAddResolveTextViewCell = interventionDisplayTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
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
            if let textViewCell : DCInterventionAddResolveTextViewCell = interventionDisplayTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
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
    
    func presentNextMedication () {
        
        //Present view with next medication, if in case of multiple selection.
        //Clousure "interventionUpdated" is called to pass data back to parent.
        self.interventionUpdated(self.medicationList[self.indexOfCurrentMedication!] as! DCMedicationScheduleDetails)
        indexOfCurrentMedication!++
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
}
