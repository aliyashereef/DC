//
//  DCInterventionAddOrResolveViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 30/03/16.
//
//

import UIKit

typealias InterventionUpdated = (DCMedicationScheduleDetails) -> Void

class DCInterventionAddOrResolveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var interventionType : InterventionType?
    var medicationList : NSMutableArray = []
    var index : Int?
    var interventionUpdated: InterventionUpdated = { value in }

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
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: SAVE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
        self.navigationItem.rightBarButtonItem = doneButton
            self.navigationItem.title = medicationList[index!].name
            self.title = medicationList[index!].name
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if interventionType == eAddIntervention {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 90
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (interventionType!.rawValue) {
        case eAddIntervention.rawValue:
            let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
            cell!.placeHolderString = REASON_TEXT
            cell?.initializeTextView()
            return cell!
        case eResolveIntervention.rawValue:
            if indexPath.section == eZerothSection.rawValue {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_CELL) as? DCInterventionAddOrResolveTableCell
                return cell!
            } else {
                let cell = interventionDisplayTableView.dequeueReusableCellWithIdentifier(REASON_RESOLVE_TEXTVIEW_CELL) as? DCInterventionAddResolveTextViewCell
                cell!.placeHolderString = RESOLUTION_TEXT
                cell?.initializeTextView()
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
        
        self.presentNextMedication()
    }
    
    func doneButtonPressed() {
    
        if interventionType == eAddIntervention {
            if let textViewCell : DCInterventionAddResolveTextViewCell = interventionDisplayTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                if textViewCell.reasonOrResolveTextView.text != REASON_TEXT && textViewCell.reasonOrResolveTextView.text != "" && textViewCell.reasonOrResolveTextView.text != nil {
                    //Add to reason
                    let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[index!] as! DCMedicationScheduleDetails
                    //Save name of the pharmacist who created the intervention.
                    medicationSheduleDetails.pharmacistAction.intervention.createdBy = ""
                    //Save the time at which the intervention is created.
                    medicationSheduleDetails.pharmacistAction.intervention.createdOn = ""
                    medicationSheduleDetails.pharmacistAction.intervention.reason = textViewCell.reasonOrResolveTextView.text
                    self.presentNextMedication()
                } else {
                    textViewCell.reasonOrResolveTextView.textColor = UIColor.redColor()
                }
            }
        } else {
            if let textViewCell : DCInterventionAddResolveTextViewCell = interventionDisplayTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                if textViewCell.reasonOrResolveTextView.text != RESOLUTION_TEXT && textViewCell.reasonOrResolveTextView.text != "" && textViewCell.reasonOrResolveTextView.text != nil {
                    let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[index!] as! DCMedicationScheduleDetails
                    medicationSheduleDetails.pharmacistAction.intervention.resolution = textViewCell.reasonOrResolveTextView.text
                    self.presentNextMedication()
                } else {
                    textViewCell.reasonOrResolveTextView.textColor = UIColor.redColor()
                }
            }
        }
    }
    
    func presentNextMedication () {
        
        self.interventionUpdated(self.medicationList[self.index!] as! DCMedicationScheduleDetails)
        index!++
        if index < medicationList.count {
            self.dismissViewControllerAnimated(true, completion: {() -> Void in
                let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
                addInterventionViewController!.index = self.index!
                addInterventionViewController?.medicationList = self.medicationList
                addInterventionViewController?.interventionType = self.interventionType
                addInterventionViewController!.interventionUpdated = { value in
                    self.interventionUpdated(value)
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
