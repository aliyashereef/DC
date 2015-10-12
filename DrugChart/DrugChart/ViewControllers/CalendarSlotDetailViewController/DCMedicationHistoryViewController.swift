
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

    //Configuring the basic view with the medication details, route and time
    
func configureMedicationDetails () {
    medicationNameLabel.text = medicationDetails!.name
    if (medicationDetails?.route != nil) {
        populateRouteAndInstructionLabels()
    }
    let dateString : String
    if let date = medicationSlot?.time {
        dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
    } else {
        dateString = DCDateUtility.convertDate(weekDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
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
            instructionString = " (As Directed)"
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
            cell!.value.text = IS_GIVEN
            break
        case 1:
            cell!.contentType.text = ADMINISTRATED_BY
            let administratedBy : String
            if let name = medicationSlot?.medicationAdministration?.administratingUser?.displayName {
                administratedBy = name
            } else {
                administratedBy = "Julia Antony"
            }
            cell!.value.text = administratedBy
            break
        case 2:
            cell!.contentType.text = DATE_TIME
            let dateString : String
            if let date = medicationSlot?.medicationAdministration?.actualAdministrationTime {
                dateString = DCDateUtility.convertDate(DCDateUtility.getDateInCurrentTimeZone(date), fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            } else {
                dateString = DCDateUtility.convertDate(weekDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: ADMINISTER_DATE_TIME_FORMAT)
            }
            cell!.value.text = dateString
            break
        case 3:
            cell!.contentType.text = CHECKED_BY
            let checkedBy : String
            if let name = medicationSlot?.medicationAdministration?.checkingUser?.displayName {
                checkedBy = name
            } else {
                checkedBy = "Andrea Thomas"
            }
            cell!.value.text = checkedBy
            break
        case 4:
            cell!.contentType.text = BATCHNO_EXPIRY
            cell!.value.text = (medication.medicationAdministration?.batch != nil) ? medication.medicationAdministration?.batch : EMPTY_STRING
            break
        case 5:
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:NOTES)
        default:
            break
        }
        return cell!
    }
    
    // configuring the notes and reason cell for medication status display for the patient.
    func configureNotesAndReasonCellsAtIndexPath (indexPath : NSIndexPath, type : NSString ) -> DCNotesAndReasonCell {
        
        var noteCell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(NOTES_AND_REASON_CELL) as? DCNotesAndReasonCell
        if noteCell == nil {
            noteCell = DCNotesAndReasonCell(style: UITableViewCellStyle.Value1, reuseIdentifier:NOTES_AND_REASON_CELL)
        }
        noteCell!.moreButton.tag = indexPath.row
        noteCell!.moreButton.addTarget(self, action: "moreButtonPressed:", forControlEvents: .TouchUpInside)
        noteCell!.cellContentTypeLabel!.text = type as String
        //Handle the cases for notes based on actual status
        if (medicationSlot?.medicationAdministration?.administeredNotes != nil) {
            noteCell!.reasonTextLabel.text = medicationSlot?.medicationAdministration?.administeredNotes
        } else {
            noteCell!.reasonTextLabel.text = EMPTY_STRING
            noteCell!.isNotesExpanded = true
        }
        //noteCell!.reasonTextLabel.text = DUMMY_TEXT
        if(noteCell!.isNotesExpanded == false) {
            noteCell!.moreButtonWidthConstaint.constant = 46.0
            noteCell!.reasonTextLabelTopSpaceConstraint.constant = 11.0
            noteCell!.reasonLabelLeadingSpaceConstraint.constant = 300.0
        } else {
            noteCell!.moreButtonWidthConstaint.constant = 0.0
            noteCell!.reasonTextLabelTopSpaceConstraint.constant = 25.0
            noteCell!.reasonLabelLeadingSpaceConstraint.constant = 7.0
        }
        noteCell!.isNotesExpanded = false
        noteCell!.layoutMargins = UIEdgeInsetsZero
        return noteCell!
    }
    
    // Configuring the medication details cell
    func configureMedicationDetailsCellAtIndexPath(indexPath : NSIndexPath) -> (DCMedicationDetailsCell) {
        
        var detailsCell  = medicationHistoryTableView.dequeueReusableCellWithIdentifier(MEDICATION_CELL_ID) as? DCMedicationDetailsCell
        if detailsCell == nil {
            detailsCell = DCMedicationDetailsCell(style: UITableViewCellStyle.Value1, reuseIdentifier:MEDICATION_CELL_ID)
        }
        if let medicationDetail = medicationDetails {
            detailsCell!.populateCellWithMedicationDetails(medicationDetail)
        }
        detailsCell!.layoutMargins = UIEdgeInsetsZero
        return detailsCell!
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
            cell!.value.text = "14-Jun-2015"
            break
        case 2:
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:REASON)
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
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:REASON)
        default:
            break
        }
        cell!.layoutMargins = UIEdgeInsetsZero
        return cell!
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
            if medicationValue.medicationAdministration?.status == IS_GIVEN {
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

    //MARK: TableView Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let historyArray : [DCMedicationSlot] = medicationSlotArray {
            return historyArray.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRowsFromMedicationSlotArray(medicationSlotArray[section])
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       if(indexPath == selectedRowIndex ) {
            return 100
        } else {
            return 44
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(ADMINSTER_MEDICATION_HISTORY_CELL) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: ADMINSTER_MEDICATION_HISTORY_CELL)
        }
//<<<<<<< HEAD
//        if indexPath.section == 0 {
//            switch (indexPath.row) {
//            case 0:
//                let dateString : String
//                if let date = medicationSlot?.time {
//                    dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
//                } else {
//                    dateString = DCDateUtility.convertDate(weekDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
//                }
//                cell!.contentType.text = dateString
//                cell!.value.text = EMPTY_STRING
//                cell!.layoutMargins = UIEdgeInsetsZero
//                break
//            case 1:
//                
//                return configureMedicationDetailsCellAtIndexPath(indexPath)
//            default:
//                break
//            }
//        } else {
//            let medication : DCMedicationSlot = medicationSlotArray[indexPath.section-1]
//            if medication.medicationAdministration?.status == IS_GIVEN {
//=======
        let medication : DCMedicationSlot = medicationSlotArray[indexPath.section]
            if medication.status == IS_GIVEN {
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
        
//        if(section == 0) {
//            return 0
//        } else {
//            let medication : DCMedicationSlot = medicationSlotArray[section-1]
//            return (medication.medicationAdministration?.status != nil) ? 40.0 : 0.0
//        }
        return 40.0
    }
    
    // returns the header view
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.instanceFromNib()
        let medication : DCMedicationSlot = medicationSlotArray[section]
        if medication.medicationAdministration?.status == IS_GIVEN {
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
