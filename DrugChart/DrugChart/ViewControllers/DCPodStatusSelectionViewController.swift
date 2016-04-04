//
//  DCPodStatusSelectionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 04/04/16.
//
//

import UIKit

let podStatusArray = [PATIENT_OWN_DRUG,PATIENT_OWN_DRUG_HOME,PATIENT_OWN_AND_HOME]

class DCPodStatusSelectionViewController: UIViewController {

    var medicationList : NSMutableArray = []
    var index : Int?
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case SectionCount.eZerothSection.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(POD_STATUS_CELL) as? DCPodStatusTableViewCell
            cell?.podStatusLabel.text = podStatusArray[indexPath.row]
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
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func cancelButtonPressed() {
        
        self.presentNextMedication()
    }
    
    func doneButtonPressed() {
        
        if let textViewCell : DCInterventionAddResolveTextViewCell = updatePodStatusTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
            if textViewCell.reasonOrResolveTextView.text != NOTES && textViewCell.reasonOrResolveTextView.text != "" && textViewCell.reasonOrResolveTextView.text != nil {
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
    }
    
    func presentNextMedication () {
        
        index!++
        if index < medicationList.count {
            self.dismissViewControllerAnimated(true, completion: {() -> Void in
                let updatePodStatusViewController : DCPodStatusSelectionViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(UPDATE_POD_STATUS_SB_ID) as? DCPodStatusSelectionViewController
                    updatePodStatusViewController?.medicationList = self.medicationList
                updatePodStatusViewController!.index = self.index!
                let navigationController: UINavigationController = UINavigationController(rootViewController: updatePodStatusViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(navigationController, animated: true, completion: { _ in })
            })
        } else {
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
