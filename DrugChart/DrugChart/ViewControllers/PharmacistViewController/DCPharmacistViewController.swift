//
//  DCPharmacistViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/29/16.
//
//

import UIKit

class DCPharmacistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pharmacistTableView: UITableView!
    @IBOutlet weak var medicationCountLabel: UILabel!
    @IBOutlet weak var medicationCountToolBar: UIToolbar!
    @IBOutlet weak var pharmacistActionsToolBar: UIToolbar!
    
    var medicationList : NSMutableArray = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureNavigationBar()
        configureMedicationCountToolBar()
        pharmacistTableView.allowsMultipleSelectionDuringEditing = true
        self.configureToolBarsForEditingState(false)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private Methods
    
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
        
        if isEditing == false {
            medicationCountToolBar.hidden = false
            pharmacistActionsToolBar.hidden = true
        } else {
            medicationCountToolBar.hidden = true
            pharmacistActionsToolBar.hidden = false
        }
    }

    // MARK: TableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return medicationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let pharmacistCell = tableView.dequeueReusableCellWithIdentifier(PHARMACIST_CELL_ID, forIndexPath: indexPath) as? DCPharmacistTableCell
        let medicationDetails = medicationList[indexPath.item]
        pharmacistCell?.fillMedicationDetailsInTableCell(medicationDetails as! DCMedicationScheduleDetails)
        return pharmacistCell!
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Insert
    }
    
    // MARK: Action Methods
    
    func editButtonPressed(sender : NSObject) {
        
        pharmacistTableView.setEditing(true, animated: true)
        configureToolBarsForEditingState(true)
        self.addNavigationRightBarButtonItemForEditingState(true)
    }
    
    func cancelButtonPressed(sender : NSObject) {
        
        pharmacistTableView.setEditing(false, animated: true)
        configureToolBarsForEditingState(false)
        self.addNavigationRightBarButtonItemForEditingState(false)
    }

    @IBAction func verifyClinicalCheckButtonPressed(sender: AnyObject) {
        
        print("***** Verify Clinical Check Action")
    }
    
    
    @IBAction func invalidateClinicalCheckButonPressed(sender: AnyObject) {
        
        print("((((( Invalidate Clinical Remove action ")
    }
    
    @IBAction func AddInterventionButtonPressed(sender: AnyObject) {

        print("***** Add Intervention Button Action")
        let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
        addInterventionViewController?.medicationList = medicationList
        addInterventionViewController?.interventionType = eAddIntervention
        let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func resolveInterventionButtonPressed(sender: AnyObject) {
        
        print("***** Resolve Intervention Button Action")
        let addInterventionViewController : DCInterventionAddOrResolveViewController? = UIStoryboard(name: PHARMACIST_ACTION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_ADD_RESOLVE_SB_ID) as? DCInterventionAddOrResolveViewController
        addInterventionViewController?.medicationList = medicationList
        addInterventionViewController?.interventionType = eResolveIntervention
        let navigationController: UINavigationController = UINavigationController(rootViewController: addInterventionViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func updatePODStatusButtonPressed(sender: AnyObject) {
        
        print("update Pod status")
    }
    
}
