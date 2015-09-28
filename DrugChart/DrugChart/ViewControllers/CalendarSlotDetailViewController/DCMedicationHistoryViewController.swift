
//
//  DCMedicationHistoryViewController.swift
//  DrugChart
//
//  Created by aliya on 22/09/15.
//
//

import Foundation
import UIKit

class DCMedicationHistoryViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, MoreButtonDelegate {
    
    var medicationSlotArray: [Dictionary<String, Int>] = []
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?
    @IBOutlet var medicationHistoryTableView: UITableView!
    var selectedRowIndex : NSIndexPath = NSIndexPath(forRow: -1, inSection: 0)
    var indexPathArray : [NSIndexPath] = []
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return 2
        case 1:
            return 6
        case 2:
            return 2
        case 3:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0 && indexPath.row == 1) {
            return 90
        } else if(indexPath == selectedRowIndex ) {
            return 100
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "AdministerCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? DCAdminsteredMedicationCell
        if cell == nil {
            cell = DCAdminsteredMedicationCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        if indexPath.section == 0 {
            switch (indexPath.row) {
            case 0:
                cell!.contentType.text = "14 December 2015"
                cell!.value.text = EMPTY_STRING
                break
            case 1:
                let cellIdentifier = "MedicationDetailsCell"
                var detailsCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? DCMedicationDetailsCell
                if detailsCell == nil {
                    detailsCell = DCMedicationDetailsCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
                }
                detailsCell!.medicineName.text = "Methotrexate 10 mg tablets"
                detailsCell!.routeAndInstructionLabel.text = "Oral (As directed by doctor)"
                detailsCell!.dateLabel.text = "14 December 2015"
                return detailsCell!
            default:
                break
            }
        }
        else if (indexPath.section == 1) {
            
            switch (indexPath.row) {
            case 0:
                cell!.contentType.text = "Status"
                cell!.value.text = "Administered"
                break
            case 1:
                cell!.contentType.text = "Administered By"
                cell!.value.text = "Julia Antony"
                break
            case 2:
                cell!.contentType.text = "Date & Time"
                cell!.value.text = "16-Sept-2015 21:00"
                break
            case 3:
                cell!.contentType.text = "Checked By"
                cell!.value.text = "Andrea Thomas"
                break
            case 4:
                cell!.contentType.text = "Batch No/Expiry Date"
                cell!.value.text = "14-Dec-2015"
                break
            case 5:
                return configureNotesAndReasonCellsAtIndexPath(indexPath,type:"Notes")
            default:
            break
            }
        }
        else if (indexPath.section == 2) {
            switch (indexPath.row) {
            case 0:
                cell!.contentType.text = "Status"
                cell!.value.text = "Omitted"
                break
            case 1:
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:"Reason")
            default:
                break
            }
        }
        else if (indexPath.section == 3) {
            switch (indexPath.row) {
            case 0:
                cell!.contentType.text = "Status"
                cell!.value.text = "Refused"
                break
            case 1:
                cell!.contentType.text = "Date"
                cell!.value.text = "14-Dec-2015"
                break
            case 2:
            return configureNotesAndReasonCellsAtIndexPath(indexPath,type:"Reason")
            default:
                break
            }
        }
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 0
        } else {
            return 50.0
        }
    }
    
    func instanceFromNib() -> DCMedicationHistoryHeaderView {
        return UINib(nibName: "DCMedicationHistoryHeaderView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DCMedicationHistoryHeaderView
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.instanceFromNib()
        if (section == 1) {
            headerView.administratingTime.text = "06:00"
            headerView.medicationStatusImageView.image = UIImage(named :"historyTick")
        }
        else if (section == 2) {
            headerView.administratingTime.text = "12:00"
            headerView.medicationStatusImageView.image = UIImage(named :"historyCaution")
        }
        else if (section == 3) {
            headerView.administratingTime.text = "15:00"
            headerView.medicationStatusImageView.image = UIImage(named :"historyClose")
        }

        let header = UIView(frame: CGRectMake(0, 0, 100,50))
        headerView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        header.addSubview(headerView)
        return header
    }
    
    func configureNotesAndReasonCellsAtIndexPath (indexPath : NSIndexPath, type : NSString ) -> DCNotesAndReasonCell {
        let cellIdentifier = "NoteAndReasonCell"
        var noteCell = medicationHistoryTableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? DCNotesAndReasonCell
        if noteCell == nil {
            noteCell = DCNotesAndReasonCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        noteCell?.delegate = self
        noteCell!.moreButton.tag = indexPath.row
        noteCell!.cellContentTypeLabel!.text = type as String
        noteCell!.reasonTextLabel.text = "Lorem Ipsum is simply dummy text of the printing and types etting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s"
        if(noteCell!.isNotesExpanded == false) {
            noteCell!.moreButtonWidthConstaint.constant = 46.0
            noteCell!.reasonTextLabelTopSpaceConstraint.constant = 11.0
            noteCell!.reasonLabelLeadingSpaceConstraint.constant = 300.0
        } else {
            noteCell!.moreButtonWidthConstaint.constant = 0.0
            noteCell!.reasonTextLabelTopSpaceConstraint.constant = 25.0
            noteCell!.reasonLabelLeadingSpaceConstraint.constant = 15.0
        }
        noteCell!.isNotesExpanded = false
        return noteCell!
    }
    
    // Mark - Delegate Methods
    func moreButtonPressed(selectedIndexPath : NSIndexPath) {
        selectedRowIndex = selectedIndexPath
        medicationHistoryTableView.reloadData()
        }
}
