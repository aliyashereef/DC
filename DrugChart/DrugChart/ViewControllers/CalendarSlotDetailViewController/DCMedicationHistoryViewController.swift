
//
//  DCMedicationHistoryViewController.swift
//  DrugChart
//
//  Created by aliya on 22/09/15.
//
//

import Foundation
import UIKit

class DCMedicationHistoryViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var noMedicationHistoryMessageLabel: UILabel!
    @IBOutlet var medicationHistoryTableView: UITableView!
    
    var medicationSlotArray: [DCMedicationSlot] = []
    var medicationDetails : DCMedicationScheduleDetails!
    var weekDate : NSDate?
    var medication : DCMedicationSlot!
    var selectedRowIndex : NSIndexPath = NSIndexPath(forRow: -1, inSection: 1)
    
    //MARK: Memory Management Methods
    
    override func viewDidLoad() {
        medication = medicationSlotArray[0]
        medicationHistoryTableView.tableFooterView = UIView(frame: CGRectZero)
        self.medicationHistoryTableView.rowHeight = UITableViewAutomaticDimension
        self.medicationHistoryTableView.estimatedRowHeight = 44.0
        if medicationSlotArray.count == 0 {
            noMedicationHistoryMessageLabel.hidden = false
        } else {
            noMedicationHistoryMessageLabel.hidden = true
        }
        configureNavigationBar()
        super.viewDidLoad()
    }
    
    func configureNavigationBar() {
        //Navigation bar title string
        let dateString : String
        if let date = medication.time {
            dateString = DCDateUtility.dateStringFromDate(date, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        } else {
            dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: DATE_MONTHNAME_YEAR_FORMAT)
        }
        let slotDate = DCDateUtility.dateStringFromDate(medication.time, inFormat: TWENTYFOUR_HOUR_FORMAT)
        
        self.title = "\(dateString), \(slotDate)"
    }
    
    func configureAdministeredCellAtIndexPathWithMedicationSlot (indexPath : NSIndexPath ,medication : DCMedicationSlot) -> AnyObject {
        
        var cell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
        cell?.contentType.textColor = UIColor.blackColor()
        switch (indexPath.row) {
        case 0:
            cell!.contentType.text = OUTCOME
            if let status = medication.medicationAdministration?.status {
                if status == SELF_ADMINISTERED {
                    cell!.value.text = ADMINISTERED
                } else {
                    cell!.value.text = status
                }
            }
            break
        case 1:
            cell!.contentType.text = REASON
            if let reason = medication.medicationAdministration.statusReason {
                if (reason != EMPTY_STRING){
                    cell!.value.text = reason
                } else {
                    cell!.value.text = NONE_TEXT
                }
            } else {
                cell!.value.text = NONE_TEXT
            }
            break
        case 2:
            cell!.contentType.text = DOSE
            let doseString : String
            if let dose = medication.medicationAdministration?.dosageString {
                doseString = dose
            } else {
                doseString = medicationDetails.dosage
            }
            cell!.value.text = doseString
            break
        case 3:
            cell!.contentType.text = DATE_TIME
            let dateString : String
            if let date = medication.medicationAdministration?.actualAdministrationTime {
                dateString = DCDateUtility.dateStringFromDate(date, inFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell!.value.text = dateString
            break
        case 4:
            cell!.contentType.text = CHECKED_BY
            let checkedBy : String
            if let name = medication.medicationAdministration?.checkingUser?.displayName {
                checkedBy = name
            } else {
                checkedBy = NONE_TEXT
            }
            cell!.value.text = checkedBy
            break
        case 5:
            cell!.contentType.text = BATCH_NUMBER
            if medication.medicationAdministration?.batch?.characters.count > 0 {
                cell!.value.text = medication.medicationAdministration?.batch
            } else {
                cell!.value.text = NONE_TEXT
            }
            break
        case 6:
            cell!.contentType.text = EXPIRY_DATE_STRING
            var dateString = EMPTY_STRING
            if let date = medication.medicationAdministration?.expiryDateTime {
                dateString = DCDateUtility.dateStringFromDate(date, inFormat: EXPIRY_DATE_FORMAT)
                cell!.value.text = dateString
            }else {
                cell!.value.text = NONE_TEXT
            }
            break
        case 7:
            let reason : NSString
            if let reasonText = medication.medicationAdministration?.administeredNotes {
                reason = (reasonText == EMPTY_STRING) ? NONE_TEXT : reasonText
            } else {
                reason = NONE_TEXT
            }
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:NOTES, text : reason)
        default:
            break
        }
        return cell!
    }
    
    // configuring the notes and reason cell for medication status display for the patient.
    
    func configureNotesAndReasonCellsAtIndexPath (indexPath : NSIndexPath, type : NSString ,text : NSString) -> DCNotesAndReasonCell {
        
        var noteCell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(NOTES_AND_REASON_CELL) as? DCNotesAndReasonCell
        if noteCell == nil {
            noteCell = DCNotesAndReasonCell(style: UITableViewCellStyle.Value1, reuseIdentifier:NOTES_AND_REASON_CELL)
        }
        // Adding target for the more button on the cell.
        noteCell!.moreButton.addTarget(self, action: #selector(DCMedicationHistoryViewController.moreButtonPressed(_:)), forControlEvents: .TouchUpInside)
        // Assigning value for the cell labels
        noteCell!.cellContentTypeLabel!.text = type as String
        noteCell!.reasonTextLabel.text = text as String
        //.stringByReplacingOccurrencesOfString("\n", withString: EMPTY_STRING) as String
        noteCell!.reasonTextLabel.textAlignment = .Right
        // Calculating the count of text characters and checking whether the more button have to be visible.
        let count : NSInteger = text.length
        let nextLineCharacter = "\n"
        var containsNextLine = false
        if (text.containsString(nextLineCharacter)) {
            containsNextLine = true
        } else {
            containsNextLine = false
        }
        
        if containsNextLine {
            noteCell!.isNotesExpanded = false
        } else {
            if text == NONE_TEXT || count < 47 {
                noteCell!.isNotesExpanded = true // The notes need not to be expanded further.
            }
        }
        
        if(noteCell!.isNotesExpanded == false || indexPath == selectedRowIndex ) {
            if indexPath == selectedRowIndex { // For the selected indexpath the more reason label need to be expanded.
                noteCell!.moreButtonWidthConstaint.constant = 0.0
                noteCell!.reasonTextLabel.textAlignment = .Left
                noteCell!.reasonLabelLeadingSpaceConstraint.constant = 7.0
                noteCell!.reasonTextLabelTopSpaceConstraint.constant = 30.0
            } else {
                noteCell!.moreButtonWidthConstaint.constant = 46.0
                noteCell!.reasonTextLabelTopSpaceConstraint.constant = 11.0
                noteCell!.reasonLabelLeadingSpaceConstraint.constant = 200.0
                noteCell!.reasonTextLabel.textAlignment = .Right
            }
        } else {
            noteCell!.moreButtonWidthConstaint.constant = 0.0
            noteCell!.reasonTextLabel.textAlignment = .Right
            noteCell!.reasonTextLabelTopSpaceConstraint.constant = 11.0
            noteCell!.reasonLabelLeadingSpaceConstraint.constant = 200.0
        }
        if indexPath != selectedRowIndex && count > 47{
            noteCell!.moreButtonWidthConstaint.constant = 46.0
        }
        //        noteCell!.separatorInset = UIEdgeInsetsZero
        //        noteCell!.layoutMargins = UIEdgeInsetsZero
        return noteCell!
    }
    
    // configuring the refused medication status display for the patient.
    
    func configureRefusedCellAtIndexPathForMedicationDetails (indexPath : NSIndexPath , medication : DCMedicationSlot) -> AnyObject {
        var cell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
        cell?.contentType.textColor = UIColor.blackColor()
        switch (indexPath.row) {
        case 0:
            cell!.contentType.text = OUTCOME
            cell!.value.text = NOT_ADMINISTRATED
            break
        case 1:
            cell!.contentType.text = REASON
            if let reason = medication.medicationAdministration.statusReason {
                if (reason != EMPTY_STRING){
                    cell!.value.text = reason
                } else {
                    cell!.value.text = NONE_TEXT
                }
            } else {
                cell!.value.text = NONE_TEXT
            }
            break
        case 2:
            cell!.contentType.text = DOSE
            let dateString : NSString
            if let date = medication.medicationAdministration?.actualAdministrationTime {
                dateString = DCDateUtility.dateStringFromDate(date, inFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.dateStringFromDate(NSDate(), inFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell!.value.text = dateString as String
            break
        case 3:
            let reason : NSString
            if let reasonText = medication.medicationAdministration?.refusedNotes {
                reason =  (reasonText == EMPTY_STRING) ? NONE_TEXT : reasonText
            } else {
                reason = NONE_TEXT
            }
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:NOTES,text : reason)
        default:
            break
        }
        return cell!
    }
    
    // configuring the ommitted medication status display for the patient.
    
    func configureOmittedCellAtIndexPathForMedicationDetails (indexPath : NSIndexPath , medication : DCMedicationSlot) -> AnyObject {
        var cell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
        switch (indexPath.row) {
        case 0:
            cell!.contentType.text = OUTCOME
            cell!.value.text = OMITTED
            break
        case 1:
            let reason : NSString
            if let reasonText = medication.medicationAdministration?.omittedNotes {
                reason =  (reasonText == EMPTY_STRING) ? NONE_TEXT : reasonText
            } else {
                reason = NONE_TEXT
            }
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:REASON, text: reason)
        default:
            break
        }
        return cell!
    }
    
    //MARK: TableView Delegate Methods
    //Returns the number of sections in the table view.The number od medication history slots determines the number of sections.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let _ : [DCMedicationSlot] = medicationSlotArray {
            if medication.isOverridenAdministration {
                return 4
            } else {
                return 3
            }
        } else {
            return 1
        }
    }
    
    //The number of rows is determined by the medication slot status, if is administrated, the section will require 6 rows, if ommitted it may require 2 rows and 3 for the refused state.
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            return 1
        case 1:
            if medication.isOverridenAdministration {
                return 1
            } else {
                return numberOfRowsFromMedicationSlotArray(medication)
            }
        case 2 :
            if medication.isOverridenAdministration {
                return numberOfRowsFromMedicationSlotArray(medication)
            } else {
                return 1
            }
        case 3:
            return 1
        default:
            return numberOfRowsFromMedicationSlotArray(medication)
        }
    }
    
    //The height of the table view row is the default for every rows other than the notes cell.
    //Upon expansion we adjust the size of the row according size of the text.
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }
        if(indexPath == selectedRowIndex ) {
            var notesString = EMPTY_STRING
            if medication.medicationAdministration.status == ADMINISTERED || medication.medicationAdministration.status == SELF_ADMINISTERED {
                notesString = medication.medicationAdministration.administeredNotes
            } else if medication.medicationAdministration.status == REFUSED || medication.medicationAdministration.status == NOT_ADMINISTRATED {
                notesString = medication.medicationAdministration.refusedNotes
            }else if medication.medicationAdministration.status == OMITTED {
                notesString = medication.medicationAdministration.omittedNotes
            }
            let textHeight : CGSize = DCUtility.textViewSizeWithText(notesString , maxWidth:478 , font:UIFont.systemFontOfSize(14))
            return textHeight.height + 45 // the top padding space is 30 points. + some padding of 15 px
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 :
            if DCAdministrationHelper.isMedicationDurationBasedInfusion(medicationDetails){
                let cell = tableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCDurationBasedMedicationDetailsCell
                if let _ = medicationDetails {
                    cell!.configureMedicationDetails(medicationDetails!)
                }
                return cell!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("MedicationDetailsTableViewCell") as? DCMedicationDetailsTableViewCell
                if let _ = medicationDetails {
                    cell!.configureMedicationDetails(medicationDetails!)
                }
                return cell!
            }
        case 1 :
            if medication.isOverridenAdministration {
                let cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
                cell!.contentType.text = PREVIOUS_HISTORY
                cell?.value.text = EMPTY_STRING
                cell?.contentType.textColor = UIColor.blackColor()
                cell?.accessoryType = .DisclosureIndicator
                return cell!
            } else {
                var cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
                if cell == nil {
                    cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
                }
                if (medication.medicationAdministration?.status == SELF_ADMINISTERED || medication.medicationAdministration?.status == IS_GIVEN ){
                    return configureAdministeredCellAtIndexPathWithMedicationSlot(indexPath, medication: medication) as! UITableViewCell
                } else if medication.medicationAdministration?.status == REFUSED || medication.medicationAdministration?.status == NOT_ADMINISTRATED {
                    return configureRefusedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
                } else if medication.medicationAdministration?.status == OMITTED {
                    return configureOmittedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
                }
                return cell!
            }
        case 2:
            if medication.isOverridenAdministration {
                var cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
                if cell == nil {
                    cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
                }
                if (medication.medicationAdministration?.status == SELF_ADMINISTERED || medication.medicationAdministration?.status == IS_GIVEN ){
                    return configureAdministeredCellAtIndexPathWithMedicationSlot(indexPath, medication: medication) as! UITableViewCell
                } else if medication.medicationAdministration?.status == REFUSED || medication.medicationAdministration?.status == NOT_ADMINISTRATED {
                    return configureRefusedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
                } else if medication.medicationAdministration?.status == OMITTED {
                    return configureOmittedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
                }
                return cell!
            } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
            cell!.contentType.text = OVERRIDE_ADMINISTRATION
            cell?.value.text = EMPTY_STRING
            cell?.contentType.textColor = tableView.tintColor
            return cell!
            }
        case 3 :
            let cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
            cell!.contentType.text = OVERRIDE_ADMINISTRATION
            cell?.value.text = EMPTY_STRING
            cell?.contentType.textColor = tableView.tintColor
            return cell!
        default:
            if medication.isOverridenAdministration {
                let cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
                cell!.contentType.text = OVERRIDE_ADMINISTRATION
                cell?.value.text = EMPTY_STRING
                return cell!
            } else {
                var cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
                if cell == nil {
                    cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
                }
                if (medication.medicationAdministration?.status == SELF_ADMINISTERED || medication.medicationAdministration?.status == IS_GIVEN ){
                    return configureAdministeredCellAtIndexPathWithMedicationSlot(indexPath, medication: medication) as! UITableViewCell
                } else if medication.medicationAdministration?.status == REFUSED || medication.medicationAdministration?.status == NOT_ADMINISTRATED {
                    return configureRefusedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
                } else if medication.medicationAdministration?.status == OMITTED {
                    return configureOmittedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
                }
                return cell!
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0 :
            addBNFView()
            break
        case 2:
            if !medication.isOverridenAdministration {
            if self.medication?.medicationAdministration?.status == ADMINISTERED {
                self.transitToAdministerSuccessViewController()
            } else {
                self.transitToAdministerFailureViewController()
            }
            }
            break
        case 3 :
            if self.medication?.medicationAdministration?.status == ADMINISTERED {
                self.transitToAdministerSuccessViewController()
            } else {
                self.transitToAdministerFailureViewController()
            }
        default:
            break
        }
    }
    
    //MARK: Private Methods
    func transitToAdministerSuccessViewController () {
        
        let administrationSuccessViewController : DCAdministrationSuccessViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ADMINISTER_SUCCESS_VC_STORYBOARD_ID) as? DCAdministrationSuccessViewController
        administrationSuccessViewController?.medicationSlot = self.medication
        administrationSuccessViewController?.medicationSlot?.status = self.medication?.medicationAdministration?.status
        administrationSuccessViewController?.medicationDetails = medicationDetails
        administrationSuccessViewController?.isValid = true
        administrationSuccessViewController?.isOverrideAdministration = true
        administrationSuccessViewController?.overridenAdministration = { value in
            
            self.medicationHistoryTableView.reloadData()
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: administrationSuccessViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func transitToAdministerFailureViewController() {
        
        let administrationFailureViewController : DCAdministrationFailureViewController? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ADMINISTER_FAILURE_VC_STORYBOARD_ID) as? DCAdministrationFailureViewController
        administrationFailureViewController?.medicationSlot = self.medication
        administrationFailureViewController?.medicationSlot?.status = self.medication?.medicationAdministration?.status
        administrationFailureViewController?.medicationDetails = medicationDetails
        administrationFailureViewController?.isValid = true
        administrationFailureViewController?.isOverrideAdministration = true
        administrationFailureViewController?.weekDate = self.weekDate
        administrationFailureViewController?.overridenAdministration = { value in
            
            self.medicationHistoryTableView.reloadData()
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: administrationFailureViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    // Loading the header view from the xib
    
    func instanceFromNib() -> DCMedicationHistoryHeaderView {
        return UINib(nibName: MEDICATION_HISTORY_HEADER_VIEW, bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DCMedicationHistoryHeaderView
    }
    
    // calculating the number of rows from medication slot array
    
    func numberOfRowsFromMedicationSlotArray( medicationSlot : DCMedicationSlot) -> Int {
        var rowCount : Int
        if let medicationValue : DCMedicationSlot = medicationSlot {
            if (medicationValue.medicationAdministration?.status == IS_GIVEN || medicationValue.medicationAdministration?.status == SELF_ADMINISTERED){
                rowCount = 8
            } else if medicationValue.medicationAdministration?.status == OMITTED {
                rowCount = 2
            } else if medicationValue.medicationAdministration?.status == REFUSED || medicationValue.medicationAdministration?.status == NOT_ADMINISTRATED{
                rowCount = 4
            } else {
                rowCount = 0
            }
        } else {
            rowCount = 0
        }
        return rowCount
    }
    
    // On taping more button in the cell,it gets expanded closing all othe expanded cells.
    
    func moreButtonPressed(sender: UIButton) {
        let moreButton = sender
        let view = moreButton.superview!
        let cell = view.superview as! DCNotesAndReasonCell
        if cell.isNotesExpanded {
            cell.isNotesExpanded = false
        } else {
            cell.isNotesExpanded = true
        }
        let indexPath = medicationHistoryTableView.indexPathForCell(cell)
        selectedRowIndex = indexPath!
        medicationHistoryTableView.reloadData()
    }
    
    func addBNFView () {
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        let bnfViewController : DCBNFViewController? = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
        self.navigationController?.pushViewController(bnfViewController!, animated: true)
    }
}
