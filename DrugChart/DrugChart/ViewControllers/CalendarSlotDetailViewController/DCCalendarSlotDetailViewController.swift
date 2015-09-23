//
//  DCCalendarSlotDetailViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/22/15.
//
//

import UIKit

//Constants

let ADMINISTER_SEGMENT_INDEX : NSInteger = 0
let MEDICATION_HISTORY_SEGMENT_INDEX : NSInteger = 1
let BNF_SEGMENT_INDEX : NSInteger = 2

class DCCalendarSlotDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var containerView: UIView!
    
    var administerViewController : DCAdministerViewController?
    var medicationHistoryViewController : DCMedicationHistoryViewController?
    
    var medicationSlotsArray : [DCMedicationSlot] = []
    var medicationDetails : DCMedicationScheduleDetails?
    var contentArray :[AnyObject] = []
    var slotToAdminister : DCMedicationSlot?
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private Methods
    
    func configureViewElements () {
        
        self.navigationController?.navigationBarHidden = true
        for medicationSlot : DCMedicationSlot in medicationSlotsArray {
            NSLog("time is %@", medicationSlot.time)
        }
        slotToAdminister = DCUtility.getNearestMedicationSlotToBeAdministeredFromSlotsArray(medicationSlotsArray);
        addAdministerView()
    }
    
    func addAdministerView () {
        
        //add administer view controller
        let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
        if administerViewController == nil {
            administerViewController = administerStoryboard!.instantiateViewControllerWithIdentifier(ADMINISTER_STORYBOARD_ID) as? DCAdministerViewController
            administerViewController?.medicationSlot = slotToAdminister
            administerViewController?.medicationDetails = medicationDetails
            self.addChildViewController(administerViewController!)
            administerViewController!.view.frame = containerView.bounds
            containerView.addSubview((administerViewController?.view)!)
        }
        administerViewController?.didMoveToParentViewController(self)
        containerView.bringSubviewToFront((administerViewController?.view)!)
    }
    
    func addMedicationHistoryView () {
        
        //add medication History view controller
        let MedicationHistoryStoryboard : UIStoryboard? = UIStoryboard(name:MEDICATION_HISTORY, bundle: nil)
        if medicationHistoryViewController == nil {
            medicationHistoryViewController = MedicationHistoryStoryboard!.instantiateViewControllerWithIdentifier(MEDICATION_STORYBOARD_ID) as? DCMedicationHistoryViewController
            self.addChildViewController(medicationHistoryViewController!)
            medicationHistoryViewController!.view.frame = containerView.bounds
            containerView.addSubview((medicationHistoryViewController?.view)!)
        }
        medicationHistoryViewController?.didMoveToParentViewController(self)
        containerView.bringSubviewToFront((medicationHistoryViewController?.view)!)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate Methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        let presentationController : RoundRectPresentationController = RoundRectPresentationController (presentedViewController: presented, presentingViewController: presenting)
        return presentationController
    }
    
    // MARK: Action Methods
    

    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func segmentSelected(sender: UISegmentedControl) {
        
        //segment change
        switch sender.selectedSegmentIndex {
        case ADMINISTER_SEGMENT_INDEX :
            addAdministerView()
            containerView.sendSubviewToBack((medicationHistoryViewController?.view)!)
             break
        case MEDICATION_HISTORY_SEGMENT_INDEX :
            addMedicationHistoryView()
            containerView.sendSubviewToBack((administerViewController?.view)!)
            break
            
        case BNF_SEGMENT_INDEX :
            break
        default :
            break
        }
    }
}
