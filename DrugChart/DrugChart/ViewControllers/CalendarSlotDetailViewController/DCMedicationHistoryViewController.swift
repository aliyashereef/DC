
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
    @IBOutlet var medicationDateLabel: UILabel!
    @IBOutlet var medicationTypeLabel: UILabel!
    @IBOutlet var medicationNameLabel: UILabel!
    var medicationSlotArray: [DCMedicationSlot] = []
    var medicationSlot : DCMedicationSlot!
    var medicationDetails : DCMedicationScheduleDetails!
    var weekDate : NSDate?
    var selectedRowIndex : NSIndexPath = NSIndexPath(forRow: -1, inSection: 0)

    //MARK: Memory Management Methods
    
    override func viewDidLoad() {
        medicationHistoryTableView.tableFooterView = UIView(frame: CGRectZero)
        if medicationSlotArray.count == 0 {
            noMedicationHistoryMessageLabel.hidden = false
        } else {
            noMedicationHistoryMessageLabel.hidden = true
        }
        configureMedicationDetails()
        super.viewDidLoad()
    }

    //MARK : Private Methods
    
    //Configuring the basic view with the medication details, route and time
    
    func configureMedicationDetails () {
        
        medicationNameLabel.text = medicationDetails?.name
        if (medicationDetails?.route != nil) {
            populateRouteAndInstructionLabels()
        }
        let dateString : String
        if let date = medicationSlot?.time {
            dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: DATE_MONTHNAME_YEAR_FORMAT)
        } else {
            dateString = DCDateUtility.convertDate(weekDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: DATE_MONTHNAME_YEAR_FORMAT)
        }
        medicationDateLabel.text = dateString
    }
    
    //Populating the route and instruction label.
    
    func populateRouteAndInstructionLabels() {
        let route : String = medicationDetails!.route.stringByReplacingOccurrencesOfString(" ", withString: EMPTY_STRING)
        let attributedRouteString : NSMutableAttributedString = NSMutableAttributedString(string:route, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(16.0)])
        let attributedInstructionsString : NSMutableAttributedString
        let instructionString : String
        if (medicationDetails?.instruction != EMPTY_STRING && medicationDetails?.instruction != nil) {
            instructionString = String(format: " (%@)", (medicationDetails?.instruction)!)
        } else {
            instructionString = ""
        }
        attributedInstructionsString  = NSMutableAttributedString(string: instructionString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12.0)])
        attributedRouteString.appendAttributedString(attributedInstructionsString)
        self.medicationTypeLabel.attributedText = attributedRouteString;
    }
    
    //MARK: Table Cell Configuration Methods
    // configuring the administered medication status display for the patient.
    
    func configureAdministeredCellAtIndexPathWithMedicationSlot (indexPath : NSIndexPath ,medication : DCMedicationSlot) -> AnyObject {
        
        var cell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
        switch (indexPath.row) {
        case 0:
            cell!.contentType.text = STATUS
            if let status = medication.medicationAdministration?.status {
                if status == SELF_ADMINISTERED {
                    cell!.value.text = ADMINISTERED
                } else {
                    cell!.value.text = status
                }
            }
            break
        case 1:
            cell!.contentType.text = ADMINISTRATED_BY
            let administratedBy : String
            if let name = medication.medicationAdministration?.administratingUser?.displayName {
                administratedBy = name
            } else {
                administratedBy = SELF_ADMINISTERED_TITLE
            }
            cell!.value.text = administratedBy
            break
        case 2:
            cell!.contentType.text = DATE_TIME
            let dateString : String
            if let date = medication.medicationAdministration?.actualAdministrationTime {
                dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.convertDate(weekDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell!.value.text = dateString
            break
        case 3:
            cell!.contentType.text = CHECKED_BY
            let checkedBy : String
            if let name = medication.medicationAdministration?.checkingUser?.displayName {
                checkedBy = name
            } else {
                checkedBy = DEFAULT_NURSE_NAME
            }
            cell!.value.text = checkedBy
            break
        case 4:
            cell!.contentType.text = BATCHNO_EXPIRY
            if medication.medicationAdministration?.batch?.characters.count > 0 {
                cell!.value.text = medication.medicationAdministration?.batch
            } else {
                cell!.value.text = NONE_TEXT
            }
            break
        case 5:
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
        noteCell!.moreButton.addTarget(self, action: "moreButtonPressed:", forControlEvents: .TouchUpInside)
        // Assigning value for the cell labels
        noteCell!.cellContentTypeLabel!.text = type as String
        noteCell!.reasonTextLabel.text = text as String
        // Calculating the count of text characters and checking whether the more button have to be visible.
        let count : NSInteger = text.length
        if text == NONE_TEXT || count < 47{
            noteCell!.isNotesExpanded = true // The notes need not to be expanded further.
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
        noteCell!.layoutMargins = UIEdgeInsetsZero
        return noteCell!
    }
    
    // configuring the refused medication status display for the patient.
    
    func configureRefusedCellAtIndexPathForMedicationDetails (indexPath : NSIndexPath , medication : DCMedicationSlot) -> AnyObject {
        var cell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
        switch (indexPath.row) {
        case 0:
            cell!.contentType.text = STATUS
            cell!.value.text = REFUSED
            break
        case 1:
            cell!.contentType.text = DATE
            let dateString : NSString
            if let date = medication.medicationAdministration?.actualAdministrationTime {
                dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(date), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(NSDate()), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell!.value.text = dateString as String
            break
        case 2:
            let reason : NSString
            if let reasonText = medication.medicationAdministration?.refusedNotes {
                reason = reasonText
            } else {
                reason = NONE_TEXT
            }
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:REASON,text : reason)
        default:
            break
        }
        cell!.layoutMargins = UIEdgeInsetsZero
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
            cell!.contentType.text = STATUS
            cell!.value.text = OMITTED
            break
        case 1:
            let reason : NSString
            if let reasonText = medication.medicationAdministration?.omittedNotes {
                reason = reasonText
            } else {
                reason = NONE_TEXT
            }
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:REASON, text: reason)
        default:
            break
        }
        cell!.layoutMargins = UIEdgeInsetsZero
        return cell!
    }
    
    //MARK: TableView Delegate Methods
    //Returns the number of sections in the table view.The number od medication history slots determines the number of sections.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let historyArray : [DCMedicationSlot] = medicationSlotArray {
            return historyArray.count
        } else {
            return 0
        }
    }
    
    //The number of rows is determined by the medication slot status, if is administrated, the section will require 6 rows, if ommitted it may require 2 rows and 3 for the refused state.
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRowsFromMedicationSlotArray(medicationSlotArray[section])
    }
    
    //The height of the table view row is the default for every rows other than the notes cell.
    //Upon expansion we adjust the size of the row according size of the text.
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       if(indexPath == selectedRowIndex ) {
        let medication : DCMedicationSlot = medicationSlotArray[indexPath.section]
        var notesString = EMPTY_STRING
        if medication.status == ADMINISTERED || medication.status == SELF_ADMINISTERED {
            notesString = medication.medicationAdministration.administeredNotes
        } else if medication.status == REFUSED {
            notesString = medication.medicationAdministration.refusedNotes
        }else if medication.status == OMITTED {
            notesString = medication.medicationAdministration.omittedNotes
        }
        let textHeight : CGSize = DCUtility.getTextViewSizeWithText(notesString , maxWidth:478 , font:UIFont.systemFontOfSize(14))
        return textHeight.height + 45 // the top padding space is 30 points. + some padding of 15 px
        } else {
            return 44
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
        let medication : DCMedicationSlot = medicationSlotArray[indexPath.section]
            if (medication.medicationAdministration?.status == SELF_ADMINISTERED || medication.medicationAdministration?.status == IS_GIVEN ){
                return configureAdministeredCellAtIndexPathWithMedicationSlot(indexPath, medication: medication) as! UITableViewCell
            } else if medication.medicationAdministration?.status == REFUSED {
                return configureRefusedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
            } else if medication.medicationAdministration?.status == OMITTED {
                return configureOmittedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
            }
        return cell!
    }
    
    // MARK: Header View Methods
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    // returns the header view
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.instanceFromNib()
        let medication : DCMedicationSlot = medicationSlotArray[section]
        if medication.medicationAdministration?.status == IS_GIVEN || medication.medicationAdministration?.status == SELF_ADMINISTERED {
        headerView.medicationStatusImageView.image = UIImage(named :ADMINISTRATION_HISTORY_TICK_IMAGE)
        } else if medication.medicationAdministration?.status == OMITTED {
            headerView.medicationStatusImageView.image = UIImage(named :ADMINISTRATION_HISTORY_CAUTION_IMAGE)
        } else if medication.medicationAdministration?.status == REFUSED {
            headerView.medicationStatusImageView.image = UIImage(named :ADMINISTRATION_HISTORY_CLOSE_IMAGE)
        }
        if medication.medicationAdministration?.status != nil {
            if let time : NSDate = medication.time {
                let header = UIView(frame: CGRectMake(0, 0, 100,40))
                headerView.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                header.addSubview(headerView)
                headerView.administratingTime.text = DCDateUtility.convertDate(time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: TWENTYFOUR_HOUR_FORMAT);
                return header
            }
        }
        return nil
    }
    
    //MARK: Private Methods
    // Loading the header view from the xib
    
    func instanceFromNib() -> DCMedicationHistoryHeaderView {
        return UINib(nibName: MEDICATION_HISTORY_HEADER_VIEW, bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DCMedicationHistoryHeaderView
    }
    
    // calculating the number of rows from medication slot array
    
    func getNumberOfRowsFromMedicationSlotArray( medication : DCMedicationSlot) -> Int {
        var rowCount : Int
        if let medicationValue : DCMedicationSlot = medication {
            if (medicationValue.medicationAdministration?.status == IS_GIVEN || medicationValue.medicationAdministration?.status == SELF_ADMINISTERED){
                rowCount = 6
            } else if medicationValue.medicationAdministration?.status == OMITTED {
                rowCount = 2
            } else if medicationValue.medicationAdministration?.status == REFUSED {
                rowCount = 3
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
}
