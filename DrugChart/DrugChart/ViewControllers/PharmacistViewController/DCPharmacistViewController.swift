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
    var swipedCellIndexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
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
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: EDIT_BUTTON_TITLE, style: .Done, target:self , action: Selector("editButtonPressed:"))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Done, target:self , action: Selector("cancelButtonPressed:"))
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
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if indexPath == swipedCellIndexPath {
                continue
            }
            let pharmacistCell = pharmacistTableView?.cellForRowAtIndexPath(indexPath)
                as? DCPharmacistTableCell
            pharmacistCell?.swipePrescriberDetailViewToRight()
        }
    }
    
    func presentPharmacistActionSheet() {
        
        //present pharmacist action sheet
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let clinicalCheck = UIAlertAction(title: CLINICAL_CHECK, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.clinicalCheckAction()
        })
        let clinicalRemove = UIAlertAction(title: NSLocalizedString(CLINICAL_REMOVE, comment: ""), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.clinicalRemoveAction()
        })
        let addIntervention = UIAlertAction(title: NSLocalizedString(ADD_INTERVENTION, comment: ""), style: .Default, handler: {
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
        
    }
    
    func clinicalRemoveAction() {
        
    }
    
    func addInterventionAction() {
        
        let selectedMedicationList : NSMutableArray = []
        if pharmacistTableView.indexPathsForSelectedRows?.count > 0 {
            var selectedIndexPathsArray = self.pharmacistTableView.indexPathsForSelectedRows
            for i in 0..<selectedIndexPathsArray!.count {
                let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList.objectAtIndex(selectedIndexPathsArray![i].row) as! DCMedicationScheduleDetails
                if (medicationSheduleDetails.pharmacistAction?.intervention?.reason == nil || medicationSheduleDetails.pharmacistAction?.intervention?.resolution != nil) {
                    selectedMedicationList.addObject(medicationSheduleDetails)
                } else {
                    let indexOfSelectedMedication = self.medicationList.indexOfObject(medicationSheduleDetails)
                    self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
                }
            }
            if selectedMedicationList.count > 0 {
                let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
                addInterventionViewController!.index = 0
                addInterventionViewController?.interventionType = eAddIntervention
                addInterventionViewController?.medicationList = selectedMedicationList
                addInterventionViewController!.interventionUpdated = { value in
                    let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                    self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
                }
                let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func resolveInterventionAction() {
        
        let selectedMedicationList : NSMutableArray = []
        if pharmacistTableView.indexPathsForSelectedRows?.count > 0 {
            var selectedIndexPathsArray = self.pharmacistTableView.indexPathsForSelectedRows
            for i in 0..<selectedIndexPathsArray!.count {
                let medicationSheduleDetails : DCMedicationScheduleDetails = medicationList.objectAtIndex(selectedIndexPathsArray![i].row) as! DCMedicationScheduleDetails
                if (medicationSheduleDetails.pharmacistAction?.intervention?.reason != nil && medicationSheduleDetails.pharmacistAction?.intervention?.resolution == nil) {                    selectedMedicationList.addObject(medicationSheduleDetails)
                } else {
                    let indexOfSelectedMedication = self.medicationList.indexOfObject(medicationSheduleDetails)
                    self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
                }
            }
            if selectedMedicationList.count > 0 {
                let resolveInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
                resolveInterventionViewController!.index = 0
                resolveInterventionViewController?.interventionType = eResolveIntervention
                resolveInterventionViewController?.medicationList = selectedMedicationList
                resolveInterventionViewController!.interventionUpdated = { value in
                    let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                    self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
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
            updatePodStatusViewController!.index = 0
            updatePodStatusViewController?.podStatusUpdated = { value in
                let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
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
        
        let pharmacistCell = tableView.dequeueReusableCellWithIdentifier(PHARMACIST_CELL_ID, forIndexPath: indexPath) as? DCPharmacistTableCell
        let medicationDetails = medicationList[indexPath.item]
        pharmacistCell?.pharmacistCellDelegate = self
        pharmacistCell?.indexPath = indexPath
        pharmacistCell?.fillMedicationDetailsInTableCell(medicationDetails as! DCMedicationScheduleDetails)
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
    
    func editButtonPressed(sender : NSObject) {
        
        pharmacistTableView.setEditing(true, animated: true)
        isInEditMode = true
        configureToolBarsForEditingState(true)
        self.addNavigationRightBarButtonItemForEditingState(true)
    }
    
    func cancelButtonPressed(sender : NSObject) {
        
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
        
        swipedCellIndexPath = indexPath
        self.resetSwipedCellToOriginalPosition()
    }
    
    func podStatusActionOnTableCellAtIndexPath(indexPath : NSIndexPath) {
        
        let updatePodStatusViewController : DCPodStatusSelectionViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(UPDATE_POD_STATUS_SB_ID) as? DCPodStatusSelectionViewController
        updatePodStatusViewController?.medicationList.addObject(medicationList.objectAtIndex(indexPath.row))
        updatePodStatusViewController!.index = 0
        updatePodStatusViewController?.podStatusUpdated = { value in
            let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
            self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: updatePodStatusViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func clinicalCheckActionOnTableCellAtIndexPath(indexPath : NSIndexPath) {
        
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
        if (medicationSheduleDetails.pharmacistAction?.intervention?.reason == nil || medicationSheduleDetails.pharmacistAction?.intervention?.resolution != nil) {
            // intervention not added yet or added intervention has been resolved
            let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
            addInterventionViewController?.medicationList.addObject(medicationList.objectAtIndex(indexPath.row))
            addInterventionViewController!.index = 0
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
            resolveInterventionViewController!.index = 0
            resolveInterventionViewController?.interventionType = eResolveIntervention
            resolveInterventionViewController!.interventionUpdated = { value in
                let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
            }
            let navigationController: UINavigationController = UINavigationController(rootViewController: resolveInterventionViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)        }
    }
    
}
