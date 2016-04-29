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
    
    @IBOutlet weak var clinicalCheckBarButton: UIBarButtonItem!
    @IBOutlet weak var interventionBarButton: UIBarButtonItem!
    @IBOutlet weak var updatePodStatusBarButton: UIBarButtonItem!
    @IBOutlet weak var supplyRequestBarButton: UIBarButtonItem!
    
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    var isInEditMode : Bool = false
    var medicationList : NSMutableArray = []
    var swipedCellIndexPath : NSIndexPath?
    var patientDetails : DCPatient?
    var headerHeight: CGFloat = 51
    var popOverWidth : CGFloat = 250
    var heightOffset : CGFloat = 26
    var cellHeight : CGFloat = 44
    var tableTapGesture : UITapGestureRecognizer? = nil
    var isScrolling : Bool?
   // var selectAll : Bool?
    var indexPathsArray : NSMutableArray = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureViewElements()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        configureNavigationBar()
        pharmacistTableView.reloadData()
        self.configureToolBarsForEditingState(isInEditMode)
    }
    
    // MARK: Private Methods
    
    func configureViewElements() {
        
        configureNavigationBar()
        configureMedicationCountToolBar()
        pharmacistTableView.allowsMultipleSelectionDuringEditing = true
        pharmacistTableView.allowsSelectionDuringEditing = true
        //for automatic table row height adjustment
        pharmacistTableView.tableFooterView = UIView()
        pharmacistTableView!.estimatedRowHeight = PHARMACIST_ROW_HEIGHT
        pharmacistTableView!.rowHeight = UITableViewAutomaticDimension
        self.addTapGestureToNavigationBar()
    }
    
    func configureNavigationBar() {
        
        if appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow {
            self.navigationItem.titleView = nil
            self.title = NSLocalizedString("PHARMACY_ACTIONS", comment: "title")
            let titleView: DCOneThirdCalendarNavigationTitleView = NSBundle.mainBundle().loadNibNamed("DCOneThirdCalendarNavigationTitleView", owner: self, options: nil)[0] as! DCOneThirdCalendarNavigationTitleView
            titleView.populateViewForPharmacistOneThirdScreen((patientDetails?.patientName)!, nhsNumber: (patientDetails?.nhs)!, dateOfBirth: (patientDetails?.dob)!, age: (patientDetails?.age)!)
            let headerView: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, headerHeight))
            titleView.center.x = headerView.center.x
            headerView.addSubview(titleView)
            self.pharmacistTableView.tableHeaderView = self.headerViewWithSeparatorLine(headerView)
        } else {
            self.pharmacistTableView.tableHeaderView = nil
            let titleView: DCOneThirdCalendarNavigationTitleView = NSBundle.mainBundle().loadNibNamed("DCOneThirdCalendarNavigationTitleView", owner: self, options: nil)[0] as! DCOneThirdCalendarNavigationTitleView
            titleView.populateViewForPharmacistFullScreen((patientDetails?.patientName)!, nhsNumber: (patientDetails?.nhs)!, dateOfBirth: (patientDetails?.dob)!, age: (patientDetails?.age)!)
            self.navigationItem.titleView = titleView
        }
        DCUtility.backButtonItemForViewController(self, inNavigationController: self.navigationController, withTitle:NSLocalizedString("DRUG_CHART", comment: ""))
        self.addNavigationRightBarButtonItem()
    }
    
    func configureMedicationCountToolBar() {
        
        //Medication count label
        medicationCountToolBar.hidden = false
        medicationCountLabel.text = String(format: "%d %@", medicationList.count, NSLocalizedString("MEDICATIONS", comment: ""))
    }
    
    func headerViewWithSeparatorLine(headerView: UIView) -> UIView {
        
        let separatorView: UIView = UIView(frame: CGRectMake(0, 0, headerView.frame.width, 0.5))
        separatorView.backgroundColor = pharmacistTableView.separatorColor
        separatorView.center.y = headerView.frame.height
        headerView.addSubview(separatorView)
        return headerView
    }
    
    func addNavigationRightBarButtonItem() {
        
        if pharmacistTableView.editing == false {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self,
                action: #selector(DCPharmacistViewController.editButtonPressed))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target:self,
                                                                     action: #selector(DCPharmacistViewController.cancelButtonPressed))
        }
    }
    
    func configureToolBarsForEditingState(isEditing : Bool) {
        
        if isEditing == false {
            medicationCountToolBar.hidden = false
            actionsButton.hidden = true
            medicationCountLabel.hidden = false
            pharmacistActionsToolBar.hidden = true
            self.addTapGestureToPharmacistTableView()
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
            pharmacistTableView?.removeGestureRecognizer(tableTapGesture!)
        }
    }
    
    func addTapGestureToPharmacistTableView() {
        
        //gesture to pharmacist tableview
        tableTapGesture = UITapGestureRecognizer(target: self, action: #selector(DCPharmacistViewController.tappedView(_:)))
        tableTapGesture!.numberOfTapsRequired = 1
        tableTapGesture!.cancelsTouchesInView = false
        pharmacistTableView.addGestureRecognizer(tableTapGesture!)
    }
    
    func addTapGestureToNavigationBar() {
        
        //gesture to navigation bar
        let titleBarTapGesture = UITapGestureRecognizer(target: self, action: #selector(DCPharmacistViewController.tappedView(_:)))
        titleBarTapGesture.numberOfTapsRequired = 1
        titleBarTapGesture.cancelsTouchesInView = false
        self.navigationController?.navigationBar.addGestureRecognizer(titleBarTapGesture)
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
            for index in 0 ..< indexPaths.count {
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
    
    func medicationDetailsForSelectedRows () -> NSMutableArray {
        
        let medicationArray = NSMutableArray()
        if let indexPaths = pharmacistTableView.indexPathsForSelectedRows {
            for index in 0 ..< indexPaths.count {
                let indexPath = indexPaths[index] as NSIndexPath
                let cell : DCPharmacistTableCell = (pharmacistTableView.cellForRowAtIndexPath(indexPath) as? DCPharmacistTableCell)!
                let medicationDetails : DCMedicationScheduleDetails = cell.medicationDetails!
                medicationArray.addObject(medicationDetails)
            }
        }
        return medicationArray
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
                self.indexPathsArray.removeObject(NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0))
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
                    let indexPath = NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)
                    if self.indexPathsArray.containsObject(indexPath) {
                        self.indexPathsArray.removeObject(indexPath)
                    }
                    self.pharmacistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    if self.pharmacistTableView.indexPathsForSelectedRows == nil {
                        self.cancelButtonPressed()
                    }
                }
                addInterventionViewController?.cancelClicked = { value in
                    if value {
                        self.cancelButtonPressed()
                    }
                }
                let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func editInterventionAction () {
        
        var selectedMedicationList : NSMutableArray = []
        if pharmacistTableView.indexPathsForSelectedRows?.count > 0 {
            selectedMedicationList = self.configureSelectedMedicationList(true)
            if selectedMedicationList.count > 0 {
                let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
                addInterventionViewController!.indexOfCurrentMedication = 0
                addInterventionViewController?.interventionType = eEditIntervention
                addInterventionViewController?.medicationList = selectedMedicationList
                addInterventionViewController!.interventionUpdated = { value in
                    
                    let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
                    let indexPath = NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)
                    if self.indexPathsArray.containsObject(indexPath) {
                        self.indexPathsArray.removeObject(indexPath)
                    }
                    self.pharmacistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    if self.pharmacistTableView.indexPathsForSelectedRows == nil {
                        self.cancelButtonPressed()
                    }
                }
                addInterventionViewController?.cancelClicked = { value in
                    if value {
                        self.cancelButtonPressed()
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
                    let indexPath = NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)
                    if self.indexPathsArray.containsObject(indexPath) {
                        self.indexPathsArray.removeObject(indexPath)
                    }
                    self.pharmacistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    if self.pharmacistTableView.indexPathsForSelectedRows == nil {
                        self.cancelButtonPressed()
                    }
                }
                resolveInterventionViewController?.cancelClicked = { value in
                    self.cancelButtonPressed()
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
                let indexPath = NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)
                if self.indexPathsArray.containsObject(indexPath) {
                    self.indexPathsArray.removeObject(indexPath)
                }
                self.pharmacistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                if self.pharmacistTableView.indexPathsForSelectedRows == nil {
                    self.cancelButtonPressed()
                }
            }
            updatePodStatusViewController?.cancelClicked = { value in
                self.cancelButtonPressed()
            }
            let navigationController: UINavigationController = UINavigationController(rootViewController: updatePodStatusViewController!)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    func displayPharmacistSummaryScreenForMedicationAtIndexPath(indexPath : NSIndexPath) {
        
        // pharmacist summary screen
        let summaryStoryboard : UIStoryboard? = UIStoryboard(name:SUMMARY_STORYBOARD, bundle: nil)
        let medicationSummaryViewController = summaryStoryboard!.instantiateViewControllerWithIdentifier("MedicationSummary") as? DCMedicationSummaryDisplayViewController
        medicationSummaryViewController!.summaryType = ePharmacist
        let medication: DCMedicationScheduleDetails = medicationList[indexPath.item] as! DCMedicationScheduleDetails
        medicationSummaryViewController!.scheduleId = medication.scheduleId
        medicationSummaryViewController!.medicationDetails = medication
        let navigationController: UINavigationController = UINavigationController(rootViewController: medicationSummaryViewController!)
        navigationController.modalPresentationStyle = .FormSheet
        self.presentViewController(navigationController, animated: true, completion: { _ in })
    }
    
    func resetOpenedPharmacistCellOnViewTouch() {
        
        if let indexPath = swipedCellIndexPath {
            let pharmacistCell = pharmacistTableView?.cellForRowAtIndexPath(indexPath)
                as? DCPharmacistTableCell
            pharmacistCell?.swipePrescriberDetailViewToRight()
            swipedCellIndexPath = nil
        }
    }
    
    
    func overrideBackButtonWithSelectButton() {
        
        self.navigationItem.hidesBackButton = true
        self.addSelectAllBarButton()
    }
    
    func populateIndexPathsArray() {
        
        let sections = pharmacistTableView.numberOfSections
        indexPathsArray = NSMutableArray()
        for section in 0..<sections {
            let rows = pharmacistTableView.numberOfRowsInSection(section)
            for row in 0..<rows {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                indexPathsArray.addObject(indexPath)
            }
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
        pharmacistCell?.configureCellElements()
        pharmacistCell?.fillMedicationDetailsInTableCell(medicationDetails as! DCMedicationScheduleDetails)
        // to set clear background color for selected cells
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.clearColor()
        pharmacistCell?.selectedBackgroundView = backgroundColorView
        if (indexPathsArray.containsObject(indexPath)) {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        return pharmacistCell!
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Insert
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if !isInEditMode {
            self.displayPharmacistSummaryScreenForMedicationAtIndexPath(indexPath)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            if indexPathsArray.containsObject(indexPath) {
                indexPathsArray.removeObject(indexPath)
                if indexPathsArray.count == 0 {
                    self.cancelButtonPressed()
                }
            } else {
                indexPathsArray.addObject(indexPath)
            }
        }
     }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPathsArray.containsObject(indexPath) {
            indexPathsArray.removeObject(indexPath)
            if indexPathsArray.count == 0 {
                self.cancelButtonPressed()
            }
        }
    }
    
    // MARK: Touch Events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if !isInEditMode {
            self.resetOpenedPharmacistCellOnViewTouch()
        }
    }
    
    func tappedView(gesture : UITapGestureRecognizer) {
        
        if !isInEditMode {
            self.resetOpenedPharmacistCellOnViewTouch()
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
        self.addNavigationRightBarButtonItem()
        self.overrideBackButtonWithSelectButton()
    }
    
    func cancelButtonPressed() {
        
        // radio button of tableview which denotes the edit state has to be removed
        indexPathsArray.removeAllObjects()
        showNavigationBackButton()
        pharmacistTableView.setEditing(false, animated: true)
        isInEditMode = false
        configureToolBarsForEditingState(false)
        self.addNavigationRightBarButtonItem()
    }
    
    func selectAllButtonPressed()  {
        
        // select all button action
        self.populateIndexPathsArray()
        self.addDeselectAllBarButton()
        pharmacistTableView.reloadData()
    }
    
    func showNavigationBackButton() {
        
        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.hidesBackButton = false
    }
    
    func addDeselectAllBarButton() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: DESELECT_ALL_TITLE, style: .Plain, target:self,
                                                                action: #selector(DCPharmacistViewController.deselectAllButtonPressed))
    }
    
    func addSelectAllBarButton() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: SELECT_ALL_TITLE, style: .Plain, target:self,
                                                                action: #selector(DCPharmacistViewController.selectAllButtonPressed))
    }
    
    func deselectAllButtonPressed() {
        
        self.overrideBackButtonWithSelectButton()
        indexPathsArray.removeAllObjects()
        pharmacistTableView.reloadData()
    }

    @IBAction func verifyClinicalCheckButtonPressed(sender: AnyObject) {
        
        self.toolBarButtonPopOver(CLINICAL_CHECK)
    }
    
    @IBAction func interventionButtonPressed(sender: AnyObject) {
        
        self.toolBarButtonPopOver(INTERVENTION_TEXT)
    }
    
    @IBAction func updatePodStatusButtonPressed(sender: AnyObject) {
        
        self.toolBarButtonPopOver(UPDATE_POD_STATUS)
    }
    
    @IBAction func supplyRequestButtonPressed(sender: AnyObject) {
        
        self.toolBarButtonPopOver(SUPPLY_REQUEST)
    }
    
    @IBAction func updatePODStatusButtonPressed(sender: AnyObject) {
        
        self.updatePODStatusAction()
    }
    
    @IBAction func actionsButtonPressed(sender: AnyObject) {
        
        //present action screen for iphone
        self.presentOneThirdScreenPharmacistActions()
        //self.presentPharmacistActionSheet()
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
    
    func editInterventionActionOnTableCellAtIndexPath(indexPath: NSIndexPath) {
        
        // intervention not added yet or added intervention has been resolved
        let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
        addInterventionViewController?.medicationList.addObject(medicationList.objectAtIndex(indexPath.row))
        addInterventionViewController!.indexOfCurrentMedication = 0
        addInterventionViewController?.interventionType = eEditIntervention
        addInterventionViewController!.interventionUpdated = { value in
            let indexOfSelectedMedication = self.medicationList.indexOfObject(value)
            self.pharmacistTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexOfSelectedMedication, inSection: 0)], withRowAnimation: .None)
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
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
    
    func postTableViewScrollNotificationToTableCells() {
        
        let scrollParametersDictionary: Dictionary<String,Bool>! = [IS_SCROLLING: isScrolling!]
        NSNotificationCenter.defaultCenter().postNotificationName(kPharmacistTableViewScrollNotification, object: nil, userInfo: scrollParametersDictionary)
    }
    
    // MARK: ScrollView Delegate Methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //close the opened cells
        isScrolling = true
        if let indexPath = swipedCellIndexPath {
            let pharmacistCell = pharmacistTableView?.cellForRowAtIndexPath(indexPath)
                as? DCPharmacistTableCell
            pharmacistCell?.swipePrescriberDetailViewToRight()
            swipedCellIndexPath = nil
        }
        self.postTableViewScrollNotificationToTableCells()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        isScrolling = true
        self.postTableViewScrollNotificationToTableCells()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        isScrolling = false
        self.postTableViewScrollNotificationToTableCells()
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
    
    func toolBarButtonPopOver(action: String) {
        
        let actionPopOverViewController : DCPharmacistActionPopOverViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ACTION_POPOVER_SB_ID) as? DCPharmacistActionPopOverViewController
        let navigationController: UINavigationController = UINavigationController(rootViewController: actionPopOverViewController!)
        navigationController.modalPresentationStyle = .Popover
        self.presentViewController(navigationController, animated: true, completion: { _ in })
        let presentationController: UIPopoverPresentationController = navigationController.popoverPresentationController!
        presentationController.permittedArrowDirections = .Any
        presentationController.sourceView = self.view
        
        switch action {
        case CLINICAL_CHECK:
            actionPopOverViewController!.preferredContentSize = CGSizeMake(popOverWidth, heightOffset + cellHeight * 2)
            presentationController.barButtonItem = clinicalCheckBarButton
            actionPopOverViewController?.actionType = eClinicalCheck
            actionPopOverViewController?.pharmacistActionSelectedAtIndex = { value in
                if value == 0 {
                    self.clinicalCheckAction()
                } else {
                    self.clinicalRemoveAction()
                }
            }
        case INTERVENTION_TEXT:
            actionPopOverViewController!.preferredContentSize = CGSizeMake(popOverWidth, heightOffset + cellHeight * 3)
            presentationController.barButtonItem = interventionBarButton
            actionPopOverViewController?.actionType = eIntervention
            actionPopOverViewController?.pharmacistActionSelectedAtIndex = { value in
                if value == 0 {
                    self.addInterventionAction()
                } else if value == 1 {
                    self.editInterventionAction()
                } else {
                    self.resolveInterventionAction()
                }
            }
        case UPDATE_POD_STATUS:
            actionPopOverViewController!.preferredContentSize = CGSizeMake(popOverWidth, heightOffset + cellHeight)
            presentationController.barButtonItem = updatePodStatusBarButton
            actionPopOverViewController?.actionType = eUpdatePodStatus
            actionPopOverViewController?.pharmacistActionSelectedAtIndex = { value in
                if value == 0 {
                    self.updatePODStatusAction()
                }
            }
        case SUPPLY_REQUEST:
            actionPopOverViewController!.preferredContentSize = CGSizeMake(popOverWidth, heightOffset + cellHeight * 2)
            actionPopOverViewController?.pharmacistActionSelectedAtIndex = { value in
                if value == 0 {
                    //TODO: Action for Add supply request.
                } else {
                    //TODO: Action for cancel supply request.
                }
            }
            presentationController.barButtonItem = supplyRequestBarButton
            actionPopOverViewController?.actionType = eSupplyRequest
        default:
            break
        }
    }
    
    func presentOneThirdScreenPharmacistActions() {
        
        let actionDisplayViewController : DCOneThirdScreenPharmacistActionsViewController? = UIStoryboard(name: PHARMACIST_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ONT_THIRD_ACTION_SB_ID) as? DCOneThirdScreenPharmacistActionsViewController
        actionDisplayViewController?.oneThirdPharmacistActionSelected = { indexPath in
            switch indexPath!.section {
            case SectionCount.eZerothSection.rawValue:
                if indexPath?.row == RowCount.eZerothRow.rawValue {
                    self.clinicalCheckAction()
                } else {
                    self.clinicalRemoveAction()
                }
            case SectionCount.eFirstSection.rawValue:
                if indexPath?.row == RowCount.eZerothRow.rawValue {
                    self.addInterventionAction()
                } else if indexPath?.row == RowCount.eFirstRow.rawValue {
                    self.editInterventionAction()
                } else {
                    self.resolveInterventionAction()
                }
            case SectionCount.eSecondSection.rawValue:
                if indexPath?.row == RowCount.eZerothRow.rawValue {
                    self.updatePODStatusAction()
                }
            case SectionCount.eThirdSection.rawValue:
                if indexPath?.row == RowCount.eZerothRow.rawValue {
                    //TODO: Action for Add Supply Request.
                } else {
                    //TODO: Action for cancel supply request.
                }
            default:
                break
            }
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: actionDisplayViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
}
