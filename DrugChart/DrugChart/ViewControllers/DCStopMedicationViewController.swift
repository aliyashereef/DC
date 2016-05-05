//
//  DCStopMedicationViewController.swift
//  DrugChart
//
//  Created by aliya on 25/04/16.
//
//

import Foundation

class DCStopMedicationViewController : UIViewController , NotesCellDelegate{
    
    @IBOutlet weak var stopMedicationTableView: UITableView!
    var inactiveDetails : DCInactiveDetails?
    var deleteingIndexPath: NSIndexPath?
    var isSavePressed : Bool = false
    var startDate : NSString?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureTableViewProperties()
        self.configureNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isSavePressed = false
        self.stopMedicationTableView.reloadData()
    }
    
    func configureTableViewProperties (){
        self.stopMedicationTableView.rowHeight = UITableViewAutomaticDimension
        self.stopMedicationTableView.estimatedRowHeight = 44.0
        self.stopMedicationTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = StopMedicationConstants.STOP_MEDICATION
        // Navigation bar done button
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title:CANCEL_BUTTON_TITLE, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancelButtonPressed))
        let saveButton : UIBarButtonItem = UIBarButtonItem(title:SAVE_BUTTON_TITLE, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.saveButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    //MARK: TableView Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return StopMedicationConstants.SECTION_COUNT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : DCAdministerCell = tableView.dequeueReusableCellWithIdentifier(StopMedicationConstants.REASON_CELL_ID)! as! DCAdministerCell

        switch indexPath.section {
        case eZerothSection.rawValue:
            cell.titleLabel.text = StopMedicationConstants.REASON
            cell.detailLabel.text = inactiveDetails!.reason
            if (inactiveDetails?.reason == EMPTY_STRING || inactiveDetails?.reason == nil) && isSavePressed {
                cell.titleLabel.textColor = UIColor.redColor()
            } else {
               cell.titleLabel.textColor =  UIColor.blackColor()
            }
        
        case eFirstSection.rawValue:
            return notesTableCellAtIndexPath(indexPath)
        case eSecondSection.rawValue:
            cell.titleLabel.text = StopMedicationConstants.OUTSTANDING_DOSES
            if inactiveDetails?.outstandingDose == StopMedicationConstants.SELECT_SPECIFIC_DOSES {
                cell.detailLabel.text = inactiveDetails?.outstandingSpecificDose
            } else {
                cell.detailLabel.text = inactiveDetails?.outstandingDose
            }
            if !isValidOutstandingDoses() && isSavePressed {
                cell.titleLabel.textColor = UIColor.redColor()
            } else {
                cell.titleLabel.textColor =  UIColor.blackColor()
            }
        default:
            break
        }
        return cell
    }
    
    // Notes Cell
    func notesTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCNotesTableCell) {
        
        let notesCell : DCNotesTableCell = stopMedicationTableView.dequeueReusableCellWithIdentifier(NOTES_CELL_ID) as! DCNotesTableCell
        notesCell.notesType = eNotes
        notesCell.delegate = self
        notesCell.selectedIndexPath = indexPath
        if inactiveDetails?.notes != EMPTY_STRING && inactiveDetails?.notes != nil{
            notesCell.notesTextView.text = inactiveDetails?.notes
        } else {
            notesCell.notesTextView.text = notesCell.hintText()
        }
        
        if inactiveDetails?.reason == StopMedicationConstants.OTHERS && (inactiveDetails?.notes == EMPTY_STRING || inactiveDetails?.notes == nil) && isSavePressed {
            notesCell.notesTextView.textColor = UIColor.redColor()
        } else {
            notesCell.notesTextView.textColor = UIColor(forHexString: "#8f8f95")
        }
        return notesCell
    }
    

    func cellSelectionForIndexPath (indexPath : NSIndexPath) {
        switch (indexPath.section) {
        case eZerothSection.rawValue:
            let reasonViewController = (UIStoryboard(name: STOP_MEDICATION, bundle: nil).instantiateViewControllerWithIdentifier(StopMedicationConstants.REASON_VIEW_CONTROLLER_SB_ID) as? DCStopMedicationReasonViewController)!
            reasonViewController.inactiveDetails = self.inactiveDetails
            self.navigationController!.pushViewController(reasonViewController, animated: true)
            break
        case eFirstSection.rawValue:
            break
        case eSecondSection.rawValue:
            let outstandingDoseViewController = (UIStoryboard(name: STOP_MEDICATION, bundle: nil).instantiateViewControllerWithIdentifier(StopMedicationConstants.OUTSTANDING_VIEW_CONTROLLER_SB_ID) as? DCStopMedicationOutstandingDoseViewController)!
            outstandingDoseViewController.inactiveDetails = self.inactiveDetails
            outstandingDoseViewController.startDate = self.startDate
            outstandingDoseViewController.isSavePressed = self.isSavePressed
            self.navigationController!.pushViewController(outstandingDoseViewController, animated: true)
            break
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case SectionCount.eFirstSection.rawValue:
            return NOTES_CELL_HEIGHT
        default:
            return TABLE_VIEW_ROW_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.resignKeyboard()
        cellSelectionForIndexPath(indexPath)
    }
    
    
    func notesSelected(editing : Bool, withIndexPath indexPath : NSIndexPath){
        
    }
    
    func enteredNote(note : String){
        self.inactiveDetails?.notes = note
    }
    
    func cancelButtonPressed(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButtonPressed(){
        
        isSavePressed = true
        if isStopMedicationReasonValid() {
            deleteMedication()
        } else {
            self.stopMedicationTableView.reloadData()
        }
    }
    
    
    func isStopMedicationReasonValid() -> Bool {
        var isValid = true
        if inactiveDetails?.reason == EMPTY_STRING || inactiveDetails?.reason == nil  {
            isValid = false
        } else if !isValidOutstandingDoses(){
            isValid = false
        } else if inactiveDetails?.reason == StopMedicationConstants.OTHERS && (inactiveDetails?.notes == EMPTY_STRING || inactiveDetails?.notes == nil) {
            isValid = false
        }
        return isValid
    }
    
    func  isValidOutstandingDoses () -> Bool{
        
        var isValid = true
        if inactiveDetails?.outstandingDose == StopMedicationConstants.SELECT_SPECIFIC_DOSES && (inactiveDetails?.outstandingSpecificDose == EMPTY_STRING || inactiveDetails?.outstandingSpecificDose == nil) {
            isValid = false
        } else if inactiveDetails?.outstandingDose == EMPTY_STRING || inactiveDetails?.outstandingDose == nil {
            isValid = false
        }
        return isValid
    }
    
    func  deleteMedication() {
        
        let parentView = self.presentingViewController as! UINavigationController
        let prescriberMedicationViewController : DCPrescriberMedicationViewController = parentView.viewControllers.last as! DCPrescriberMedicationViewController
        for viewController in prescriberMedicationViewController.childViewControllers {
            if viewController is DCPrescriberMedicationListViewController {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                let prescriberMedicationListViewController = viewController as! DCPrescriberMedicationListViewController
                prescriberMedicationListViewController.deleteMedicationAtIndexPath(deleteingIndexPath!)
            }
        }
    }
    
    func resignKeyboard() {
        //resign keyboard
        let notesCell : DCNotesTableCell = self.notesTableCellAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
        if (notesCell.notesTextView.isFirstResponder()) {
            notesCell.notesTextView.resignFirstResponder()
        }
        self.view.endEditing(true)
    }
}