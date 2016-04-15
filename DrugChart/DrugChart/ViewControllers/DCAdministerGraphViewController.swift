//
//  DCAdministerGraphViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 16/02/16.
//
//

import UIKit

class DCAdministerGraphViewController: DCBaseViewController, UITableViewDataSource, UITableViewDelegate {

    var medicationSlotArray: [DCMedicationSlot] = []
    var medicationDetails : DCMedicationScheduleDetails!
    var weekDate : NSDate?
    var medication : DCMedicationSlot!
    var selectedRowIndex : NSIndexPath = NSIndexPath(forRow: -1, inSection: 1)
    let minimumCount : Int = 47

    @IBOutlet weak var medicationHistoryTableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        medication = medicationSlotArray[0]
        medicationHistoryTableview.tableFooterView = UIView(frame: CGRectZero)
        self.medicationHistoryTableview.rowHeight = UITableViewAutomaticDimension
        self.medicationHistoryTableview.estimatedRowHeight = 44.0
        configureNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 || section == 1 {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("DurationBasedInfusionCell") as? DCAdministerTableViewCell
            if let _ = medicationDetails {
                cell!.configureMedicationDetails(medicationDetails!)
            }
            return cell!
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("graphDisplayCell") as? DCAdministerGraphViewCell
            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("valueCell") as? DCAdministerTableViewCell
            switch (indexPath.row) {
            case 0:
                cell!.keyLabel.text = STATUS
                if let status = medication.medicationAdministration?.status {
                    if status == SELF_ADMINISTERED {
                        cell!.valueLabel.text = ADMINISTERED
                    } else {
                        cell!.valueLabel.text = status
                    }
                }
                break
            case 1:
                cell!.keyLabel.text = DATE_TIME
                let dateString : String
                if let date = medication.medicationAdministration?.actualAdministrationTime {
                    dateString = DCDateUtility.dateStringFromDate(date, inFormat: ADMINISTER_DATE_TIME_FORMAT)
                } else {
                    dateString = DCDateUtility.dateStringFromDate(weekDate, inFormat: ADMINISTER_DATE_TIME_FORMAT)
                }
                cell!.valueLabel.text = dateString
                break
            case 2:
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            self.addBNFView()
            break
        case 1:
            break
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 2 {
            return 44
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 2 && indexPath.row == 2 {
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
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func configureNotesAndReasonCellsAtIndexPath (indexPath : NSIndexPath, type : NSString ,text : NSString) -> DCNotesAndReasonCell {
        
        var noteCell = medicationHistoryTableview.dequeueReusableCellWithIdentifier(NOTES_AND_REASON_CELL) as? DCNotesAndReasonCell
        if noteCell == nil {
            noteCell = DCNotesAndReasonCell(style: UITableViewCellStyle.Value1, reuseIdentifier:NOTES_AND_REASON_CELL)
        }
        // Adding target for the more button on the cell.
        noteCell!.moreButton.addTarget(self, action: "moreButtonPressed:", forControlEvents: .TouchUpInside)
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
            if text == NONE_TEXT || count < minimumCount {
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
    
    func addBNFView () {
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        let bnfViewController : DCBNFViewController? = administerStoryboard!.instantiateViewControllerWithIdentifier(BNF_STORYBOARD_ID) as? DCBNFViewController
        self.navigationController?.pushViewController(bnfViewController!, animated: true)
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
        let indexPath = medicationHistoryTableview.indexPathForCell(cell)
        selectedRowIndex = indexPath!
        medicationHistoryTableview.reloadData()
    }


}
