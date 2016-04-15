//
//  DCPharmacistViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/29/16.
//
//

import UIKit

let PHARMACIST_ROW_HEIGHT : CGFloat = 79.0

class DCPharmacistViewController: DCBaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, PharmacistCellDelegate {

    @IBOutlet weak var pharmacistTableView: UITableView!
    @IBOutlet weak var medicationCountLabel: UILabel!
    @IBOutlet weak var medicationCountToolBar: UIToolbar!
    @IBOutlet weak var pharmacistActionsToolBar: UIToolbar!
    @IBOutlet weak var actionsButton: UIButton!
    
    var isInEditMode : Bool = false
    var medicationList : NSMutableArray = []
    var swipedCellIndexPath : NSIndexPath?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureViewElements()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        pharmacistTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.configureToolBarsForEditingState(isInEditMode)
    }
    
    // MARK: Private Methods
    
    func configureViewElements() {
        
        configureNavigationBar()
        configureMedicationCountToolBar()
        pharmacistTableView.allowsMultipleSelectionDuringEditing = true
        //for automatic table row height adjustment
        pharmacistTableView.tableFooterView = UIView()
        pharmacistTableView!.estimatedRowHeight = PHARMACIST_ROW_HEIGHT
        pharmacistTableView!.rowHeight = UITableViewAutomaticDimension
    }
    
    func configureNavigationBar() {
        
        self.title = NSLocalizedString("MEDICATION_LIST", comment: "title")
        DCUtility.backButtonItemForViewController(self, inNavigationController: self.navigationController, withTitle:NSLocalizedString("DRUG_CHART", comment: ""))
        self.addNavigationRightBarButtonItemForEditingState(false)
    }
    
    func configureMedicationCountToolBar() {
        
        //Medication count label
        medicationCountToolBar.hidden = false
        medicationCountLabel.text = String(format: "%d %@", medicationList.count, NSLocalizedString("MEDICATIONS", comment: ""))
    }
    
    func addNavigationRightBarButtonItemForEditingState(isEditing : Bool) {
        
        if isEditing == false {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: EDIT_BUTTON_TITLE, style: .Plain, target:self , action: Selector("editButtonPressed"))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target:self , action: Selector("cancelButtonPressed"))
        }
    }
    
    func configureToolBarsForEditingState(isEditing : Bool) {
        
        let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if isEditing == false {
            medicationCountToolBar.hidden = false
            actionsButton.hidden = true
            medicationCountLabel.hidden = false
            pharmacistActionsToolBar.hidden = true
        } else {
            if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
                medicationCountToolBar.hidden = false
                pharmacistActionsToolBar.hidden = true
                medicationCountLabel.hidden = true
                actionsButton.hidden = false
            } else {
                medicationCountToolBar.hidden = true
                pharmacistActionsToolBar.hidden = false
            }
        }
    }
    
    func resetSwipedCellToOriginalPosition() {
        
        //swipe gesture - right when completion of edit/delete action
        for (index,_) in medicationList.enumerate(){
            let indexPath = NSIndexPath(forRow: index, inSection: SectionCount.eZerothSection.rawValue)
            if indexPath == swipedCellIndexPath {
                continue
            }
            let pharmacistCell = pharmacistTableView?.cellForRowAtIndexPath(indexPath)
                as? DCPharmacistTableCell
            pharmacistCell?.swipePrescriberDetailViewToRight()
        }
    }
    
    func presentPharmacistActionSheet() {
        
        //present pharmacist action sheet for iPhone instead of buttons in toolbar
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let clinicalCheck = UIAlertAction(title: CLINICAL_CHECK, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.clinicalCheckAction()
        })
        let clinicalRemove = UIAlertAction(title: CLINICAL_REMOVE, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.clinicalRemoveAction()
        })
        let addIntervention = UIAlertAction(title: ADD_INTERVENTION, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.addInterventionAction()
        })
        let resolveIntervention = UIAlertAction(title: RESOLVE_INTERVENTION, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.resolveInterventionAction()
        })
        let podStatus = UIAlertAction(title: UPDATE_POD_STATUS, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.updatePODStatusAction()
        })
        let cancelAction = UIAlertAction(title: CANCEL_BUTTON_TITLE, style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        actionMenu.addAction(clinicalCheck)
        actionMenu.addAction(clinicalRemove)
        actionMenu.addAction(addIntervention)
        actionMenu.addAction(resolveIntervention)
        actionMenu.addAction(podStatus)
        actionMenu.addAction(cancelAction)
        self.presentViewController(actionMenu, animated: true, completion: nil)
    }
    
    func clinicalCheckAction() {
        
        updatePharmacistVerificationForCheckState(false)
    }
    
    func clinicalRemoveAction() {
        
        updatePharmacistVerificationForCheckState(true)
    }
    
    func updatePharmacistVerificationForCheckState(check : Bool) {
        
         // get indexpath of selected rows, if previous check state is false, clinical check has to be done
        // if previous state is true, clinical remove action has to be done
        if let indexPaths = pharmacistTableView.indexPathsForSelectedRows {
            for var index = 0; index < indexPaths.count; ++index {
                let indexPath = indexPaths[index] as NSIndexPath
                let cell : DCPharmacistTableCell = (pharmacistTableView.cellForRowAtIndexPath(indexPath) as? DCPharmacistTableCell)!
                let medicationDetails : DCMedicationScheduleDetails = cell.medicationDetails!
                if let pharmacistAction = medicationDetails.pharmacistAction {
                    if pharmacistAction.clinicalCheck == check {
                        pharmacistAction.clinicalCheck = !check
                    }
                }
                pharmacistTableView.beginUpdates()
                pharmacistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
                pharmacistTableView.endUpdates()
            }
        }
        // cancel editing state and make corresponding changes in view
        self.cancelButtonPressed()
    }
    
    func configureSelectedMedicationList(isResolveIntervention: Bool) -> NSMutableArray {
        
        let medicationObjectsArray : NSMutableArray = []
        var selectedIndexPathsArray = self.pharmacistTableView.indexPathsForSelectedRows
        for i in 0..<selectedIndexPathsArray!.count {
            let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList.objectAtIndex(selectedIndexPathsArray![i].row) as! DCMedicationScheduleDetails
            if (medicationSheduleDetails.pharmacistAction?.intervention?.toResolve == isResolveIntervention) {
                medicationObjectsArray.addObject(medicationSheduleDetails)
            } else {
                let indexOfSelectedMedication = self.medicationList.indexOfObject(medicationSheduleDetails)
                self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
            }
        }
        return medicationObjectsArray
    }
    
    func addInterventionAction() {
        
        var selectedMedicationList : NSMutableArray = []
        if pharmacistTableView.indexPathsForSelectedRows?.count > 0 {
            selectedMedicationList = self.configureSelectedMedicationList(false)
            if selectedMedicationList.count > 0 {
                let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
                addInterventionViewController!.indexOfCurrentMedication = 0
                addInterventionViewController?.interventionType = eAddIntervention
                addInterventionViewController?.medicationList = selectedMedicationList
                addInterventionViewController!.interventionUpdated = { value in
                    let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                    self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
                    if self.pharmacistTableView.indexPathsForSelectedRows == nil {
                        // radio button of tableview which denotes the edit state has to be removed
                        self.pharmacistTableView.setEditing(false, animated: true)
                        self.isInEditMode = false
                        self.configureToolBarsForEditingState(false)
                        self.addNavigationRightBarButtonItemForEditingState(false)
                    }
                }
                let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func resolveInterventionAction() {
        
        var selectedMedicationList : NSMutableArray = []
        if pharmacistTableView.indexPathsForSelectedRows?.count > 0 {
            selectedMedicationList = self.configureSelectedMedicationList(true)
            if selectedMedicationList.count > 0 {
                let resolveInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
                resolveInterventionViewController!.indexOfCurrentMedication = 0
                resolveInterventionViewController?.interventionType = eResolveIntervention
                resolveInterventionViewController?.medicationList = selectedMedicationList
                resolveInterventionViewController!.interventionUpdated = { value in
                    let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                    self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
                    if self.pharmacistTableView.indexPathsForSelectedRows == nil {
                        // radio button of tableview which denotes the edit state has to be removed
                        self.pharmacistTableView.setEditing(false, animated: true)
                        self.isInEditMode = false
                        self.configureToolBarsForEditingState(false)
                        self.addNavigationRightBarButtonItemForEditingState(false)
                    }
                }
                let navigationController: UINavigationController = UINavigationController(rootViewController: resolveInterventionViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
            } else {
                pharmacistTableView.reloadData()
            }
        }
    }
    
    func updatePODStatusAction() {
        
        if pharmacistTableView.indexPathsForSelectedRows?.count > 0 {
            let updatePodStatusViewController : DCPodStatusSelectionViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(UPDATE_POD_STATUS_SB_ID) as? DCPodStatusSelectionViewController
            for i in 0..<self.pharmacistTableView.indexPathsForSelectedRows!.count {
                updatePodStatusViewController?.medicationList.addObject(medicationList.objectAtIndex(self.pharmacistTableView.indexPathsForSelectedRows![i].row))
            }
            updatePodStatusViewController!.indexOfCurrentMedication = 0
            updatePodStatusViewController?.podStatusUpdated = { value in
                let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
                if self.pharmacistTableView.indexPathsForSelectedRows == nil {
                    // radio button of tableview which denotes the edit state has to be removed
                    self.pharmacistTableView.setEditing(false, animated: true)
                    self.isInEditMode = false
                    self.configureToolBarsForEditingState(false)
                    self.addNavigationRightBarButtonItemForEditingState(false)
                }
            }
            let navigationController: UINavigationController = UINavigationController(rootViewController: updatePodStatusViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        }
    }

    // MARK: TableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return medicationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let pharmacistCell : DCPharmacistTableCell? = tableView.dequeueReusableCellWithIdentifier(PHARMACIST_CELL_ID, forIndexPath: indexPath) as? DCPharmacistTableCell
        let medicationDetails = medicationList[indexPath.item]
        pharmacistCell?.pharmacistCellDelegate = self
        pharmacistCell?.indexPath = indexPath
        pharmacistCell?.fillMedicationDetailsInTableCell(medicationDetails as! DCMedicationScheduleDetails)
        // to set clear background color for selected cells
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.clearColor()
        pharmacistCell?.selectedBackgroundView = backgroundColorView
        return pharmacistCell!
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Insert
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !isInEditMode {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // MARK: Action Methods
    
    func editButtonPressed() {
        
        //resetSwipedCellToOriginalPosition()
        if swipedCellIndexPath != nil {
            let pharmacistCell = pharmacistTableView?.cellForRowAtIndexPath(swipedCellIndexPath!)
                as? DCPharmacistTableCell
            pharmacistCell?.swipePrescriberDetailViewToRight()
        }
        //table view has to be in editing mode and configure the tool bar and navigation right bar button item based on that
        pharmacistTableView.setEditing(true, animated: true)
        isInEditMode = true
        configureToolBarsForEditingState(true)
        self.addNavigationRightBarButtonItemForEditingState(true)
    }
    
    func cancelButtonPressed() {
        
        // radio button of tableview which denotes the edit state has to be removed
        pharmacistTableView.setEditing(false, animated: true)
        isInEditMode = false
        configureToolBarsForEditingState(false)
        self.addNavigationRightBarButtonItemForEditingState(false)
    }

    @IBAction func verifyClinicalCheckButtonPressed(sender: AnyObject) {
        
        self.clinicalCheckAction()
    }
    
    @IBAction func invalidateClinicalCheckButonPressed(sender: AnyObject) {
        
        self.clinicalRemoveAction()
    }
    
    @IBAction func addInterventionButtonPressed(sender: AnyObject) {
        
        self.addInterventionAction()
    }
    
    @IBAction func resolveInterventionButtonPressed(sender: AnyObject) {
        
        self.resolveInterventionAction()
    }
    
    @IBAction func updatePODStatusButtonPressed(sender: AnyObject) {
        
        self.updatePODStatusAction()
    }
    
    @IBAction func actionsButtonPressed(sender: AnyObject) {
        
        //present action sheet for iphone
        self.presentPharmacistActionSheet()
    }
    
    // MARK: PharmacistCell Delegate Methods
    
    func swipeActionOnTableCellAtIndexPath(indexPath : NSIndexPath) {
        
        // reset cell to original position
        swipedCellIndexPath = indexPath
        self.resetSwipedCellToOriginalPosition()
    }
    
    func podStatusActionOnTableCellAtIndexPath(indexPath : NSIndexPath) {
        
        let updatePodStatusViewController : DCPodStatusSelectionViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(UPDATE_POD_STATUS_SB_ID) as? DCPodStatusSelectionViewController
        updatePodStatusViewController?.medicationList.addObject(medicationList.objectAtIndex(indexPath.row))
        updatePodStatusViewController!.indexOfCurrentMedication = 0
        updatePodStatusViewController?.podStatusUpdated = { value in
            let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
            self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: updatePodStatusViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func clinicalCheckActionOnTableCellAtIndexPath(indexPath : NSIndexPath) {
        
        //clinical check action on cell at indexpath
        let medication : DCMedicationScheduleDetails = medicationList.objectAtIndex(indexPath.row) as! DCMedicationScheduleDetails
        if let pharmacistAction = medication.pharmacistAction {
            pharmacistAction.clinicalCheck = !pharmacistAction.clinicalCheck
        }
        pharmacistTableView.beginUpdates()
        pharmacistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        pharmacistTableView.endUpdates()
    }
    
    func resolveInterventionActionOnTableCellAtIndexPath(indexPath : NSIndexPath) {
        
        let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList[indexPath.row] as! DCMedicationScheduleDetails
        if (medicationSheduleDetails.pharmacistAction?.intervention?.toResolve == false) {
            // intervention not added yet or added intervention has been resolved
            let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
            addInterventionViewController?.medicationList.addObject(medicationList.objectAtIndex(indexPath.row))
            addInterventionViewController!.indexOfCurrentMedication = 0
            addInterventionViewController?.interventionType = eAddIntervention
            addInterventionViewController!.interventionUpdated = { value in
                let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
            }
            let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        } else {
            let resolveInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
            resolveInterventionViewController?.medicationList.addObject(medicationList.objectAtIndex(indexPath.row))
            resolveInterventionViewController!.indexOfCurrentMedication = 0
            resolveInterventionViewController?.interventionType = eResolveIntervention
            resolveInterventionViewController!.interventionUpdated = { value in
                let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
            }
            let navigationController: UINavigationController = UINavigationController(rootViewController: resolveInterventionViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: ScrollView Delegate Methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //close the opened cells
        if let indexPath = swipedCellIndexPath {
            let pharmacistCell = pharmacistTableView?.cellForRowAtIndexPath(indexPath)
                as? DCPharmacistTableCell
            pharmacistCell?.swipePrescriberDetailViewToRight()
            swipedCellIndexPath = nil
        }
    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
        
        if pharmacistTableView.indexPathsForSelectedRows?.count > 0 {
            let alertView = UIAlertController(title: NSLocalizedString("CONFIRMATION", comment: ""), message: NSLocalizedString("PHARMACIST_UNSAVED_CHANGES", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: NO_BUTTON_TITLE, style: .Default, handler: { (alert : UIAlertAction) -> Void in
                return false
            }))
            alertView.addAction(UIAlertAction(title: YES_BUTTON_TITLE, style: .Default, handler: { (alert : UIAlertAction) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
                //return true
            }))
            self.presentViewController(alertView, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
}
