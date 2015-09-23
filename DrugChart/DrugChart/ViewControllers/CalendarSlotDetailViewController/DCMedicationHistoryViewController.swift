
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
    var medicationSlotArray: [Dictionary<String, Int>] = []

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
        if(indexPath.section == 0 && indexPath.item == 1){
            return 90
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
        if (indexPath.section == 0) {
            switch (indexPath.item) {
            case 0:
                cell!.contentType.text = "14-Dec-2015"
                break
            case 1:
                let cellIdentifier = "MedicationDetailsCell"
                var detailsCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? DCMedicationDetailsCell
                if detailsCell == nil {
                    detailsCell = DCMedicationDetailsCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
                }
                detailsCell!.medicineName.text = "Name"
                detailsCell!.routeAndInstructionLabel.text =  "Oral"
                detailsCell!.dateLabel.text = "14-Dec-2015"
                return detailsCell!
            default:
                break
            }
        }
        else if (indexPath.section == 1) {
            
            switch (indexPath.item) {
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
                cell!.contentType.text = "Notes"
                break
            default:
                break
            }
        }
        else if (indexPath.section == 2) {
            switch (indexPath.item) {
            case 0:
                cell!.contentType.text = "Status"
                cell!.value.text = "Omitted"
                break
            case 1:
                cell!.contentType.text = "Reason"
                cell!.value.text = "Lorem ipsum"
            
            default:
                break
            }
        }
        else if (indexPath.section == 3) {
            switch (indexPath.item) {
            case 0:
                cell!.contentType.text = "Status"
                cell!.value.text = "Refused"
                break
            case 1:
                cell!.contentType.text = "Reason"
                cell!.value.text = "Lorem ipsum"
            case 2:
                cell!.contentType.text = "Date"
                cell!.value.text = "14-Dec-2015"
                break
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
    
}
