
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
        super.viewDidLoad()
    }
    //MARK: Table Cell Configuration Methods
    
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
            cell!.value.text = "Julia Antony"
            break
        case 2:
            cell!.contentType.text = DATE_TIME
            //cell!.value.text = "16-Jun-2015 21:00"
            cell!.value.text = "16-Jun-2015 21:00"
            break
        case 3:
            cell!.contentType.text = CHECKED_BY
            cell!.value.text = "Andrea Thomas"
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
    
    func instanceFromNib() -> DCMedicationHistoryHeaderView {
        return UINib(nibName: MEDICATION_HISTORY_HEADER_VIEW, bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DCMedicationHistoryHeaderView
        }
        
    func getNumberOfRowsFromMedicationSlotArray( medication : DCMedicationSlot) -> Int {
        var rowCount : Int
        if let medicationValue : DCMedicationSlot = medication {
            if medicationValue.status == IS_GIVEN {
                rowCount = 6
            } else if medicationValue.status == OMITTED {
                rowCount = 2
            } else if medicationValue.status == REFUSED {
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
            return historyArray.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section) {
        case 0:
            return 2
        default:
            return getNumberOfRowsFromMedicationSlotArray(medicationSlotArray[section-1])
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0 && indexPath.row == 1) {
            return 55
        } else if(indexPath == selectedRowIndex ) {
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
        if indexPath.section == 0 {
            switch (indexPath.row) {
            case 0:
                let dateString : String
                if let date = medicationSlot?.time {
                    dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
                } else {
                    //let currentDate : NSDate = DCDateUtility.getDateInCurrentTimeZone(NSDate())
                    dateString = DCDateUtility.convertDate(weekDate, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
                }
                cell!.contentType.text = dateString
                cell!.value.text = EMPTY_STRING
                cell!.layoutMargins = UIEdgeInsetsZero
                break
            case 1:
                
                return configureMedicationDetailsCellAtIndexPath(indexPath)
            default:
                break
            }
        } else {
            let medication : DCMedicationSlot = medicationSlotArray[indexPath.section-1]
            if medication.status == IS_GIVEN {
                return configureAdministeredCellAtIndexPathWithMedicationSlot(indexPath, medication: medication) as! UITableViewCell
            } else if medication.status == REFUSED {
                return configureRefusedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
            } else if medication.status == OMITTED {
                return configureOmittedCellAtIndexPathForMedicationDetails(indexPath, medication: medication) as! UITableViewCell
            }
        }
        return cell!
    }
    
    // MARK: Header View Methods
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 0
        } else {
            return 40.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.instanceFromNib()
        let medication : DCMedicationSlot = medicationSlotArray[section-1]
        if medication.status == IS_GIVEN {
            headerView.medicationStatusImageView.image = UIImage(named :ADMINISTRATION_HISTORY_TICK_IMAGE)
        } else if medication.status == OMITTED {
            headerView.medicationStatusImageView.image = UIImage(named :ADMINISTRATION_HISTORY_CAUTION_IMAGE)
        } else if medication.status == REFUSED {
            headerView.medicationStatusImageView.image = UIImage(named :ADMINISTRATION_HISTORY_CLOSE_IMAGE)
        }
        if let time : NSDate = medication.time {
            headerView.administratingTime.text = DCDateUtility.convertDate(time, fromFormat: DEFAULT_DATE_FORMAT, toFormat: TWENTYFOUR_HOUR_FORMAT);
        } else  {
            
        }
        let header = UIView(frame: CGRectMake(0, 0, 100,40))
        headerView.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        header.addSubview(headerView)
        return header
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
