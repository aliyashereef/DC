//
//  DCAdministrationReasonViewController.swift
//  DrugChart
//
//  Created by aliya on 24/02/16.
//
//

import Foundation


protocol reasonDelegate {

    func reasonSelected(reason: String, secondaryReason : String)
}

class DCAdministrationReasonViewController : DCBaseViewController, NotesCellDelegate {
    
    let successReasonArray = ["Nurse Administered","Patient Declared Administered","Supervised Self Administered","Covertly Administered","IV Access Lost","Vomitted","Partial Administration"]
    let failureReasonArray = ["Omitted","Patient Refused","Nil by Mouth","Drug Unavailable","Not Administered other"]

    var delegate: reasonDelegate?
    var administrationStatus : String?
    var previousSelection : String?
    var secondaryReason : String?
    var NotesFieldShown : Bool = false
    
    @IBOutlet var reasonTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showOtherReasonsFieldForReason()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: TableView Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if NotesFieldShown {
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount : Int
        switch section {
        case 0:
            switch (administrationStatus!) {
            case NOT_ADMINISTRATED :
                rowCount = failureReasonArray.count
            default:
                rowCount = successReasonArray.count
            }
        case 1:
            rowCount = 1
        default:
            rowCount = 0
        }
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCellWithIdentifier("StatusReasonCell")! as UITableViewCell
        switch indexPath.section {
        case 0:
            cell.textLabel!.font = UIFont.systemFontOfSize(15.0)
            var reasonArray : NSArray = successReasonArray
            switch (administrationStatus!) {
            case NOT_ADMINISTRATED :
                reasonArray = failureReasonArray
            default:
                reasonArray = successReasonArray
            }
            cell.textLabel?.text = reasonArray[indexPath.row] as? String
            cell.accessoryType = (previousSelection! == reasonArray[indexPath.row] as? String) ? .Checkmark : .None
            return cell
        case 1:
            let notesCell : DCNotesTableCell = (tableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as? DCNotesTableCell)!
            notesCell.notesType = eReason
            notesCell.delegate = self
            notesCell.selectedIndexPath = indexPath
            if secondaryReason != EMPTY_STRING && secondaryReason != nil{
                notesCell.notesTextView.text = secondaryReason
            } else {
                notesCell.notesTextView.text = notesCell.hintText()
            }
            return notesCell
        default:
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 44
        default:
            return NOTES_CELL_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var reasonString = EMPTY_STRING
        var reasonArray = successReasonArray
        switch (administrationStatus!) {
        case NOT_ADMINISTRATED :
            reasonArray = failureReasonArray
        default:
            reasonArray = successReasonArray
        }
        reasonString = reasonArray[indexPath.row]
        if (self.delegate != nil) {
            self.delegate?.reasonSelected(reasonString, secondaryReason: EMPTY_STRING)
        }
        if indexPath.row == reasonArray.count - 1 {
            NotesFieldShown = true
            tableView.reloadData()
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        previousSelection = reasonArray[indexPath.row] as String
    }
    
    func showOtherReasonsFieldForReason () {
        var otherReasonString : String
        switch (administrationStatus!) {
        case NOT_ADMINISTRATED :
            otherReasonString = failureReasonArray[failureReasonArray.count - 1]
        default:
            otherReasonString = successReasonArray[successReasonArray.count - 1]
        }
        if previousSelection == otherReasonString {
            NotesFieldShown = true
            reasonTableView.reloadData()
        }
    }
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath) {
        
    }
    
    func enteredNote(note : String) {
        if (self.delegate != nil) {
            self.delegate?.reasonSelected(previousSelection!, secondaryReason:note)
        }
    }
    
    func keyboardDidShow(notification : NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                var offset : CGFloat
                var reasonArray = successReasonArray
                switch (administrationStatus!) {
                case NOT_ADMINISTRATED :
                    reasonArray = failureReasonArray
                    offset = (3.0 - CGFloat(reasonArray.count))*10.0
                default:
                    reasonArray = successReasonArray
                    offset = (3.0 - CGFloat(reasonArray.count))*10.0
                    offset = abs(offset)
                }
                let delayInSeconds: Double = 0.50
                let deleteTime : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(deleteTime, dispatch_get_main_queue(), {() -> Void in
                    let contentHeight : CGFloat? = self.reasonTableView.frame.height
                    let scrollOffset = contentHeight! - keyboardSize.height - NOTES_CELL_HEIGHT + offset
                    self.reasonTableView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
                })
            }
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        reasonTableView.beginUpdates()
        reasonTableView.endUpdates()
    }
}