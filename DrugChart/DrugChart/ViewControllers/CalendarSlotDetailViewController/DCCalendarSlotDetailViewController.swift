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
    
    let administerViewController : DCAdministerViewController? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
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
            
//            let administerStoryboard : UIStoryboard? = UIStoryboard(name: ADMINISTER_STORYBOARD, bundle: nil)
            
            

            break
        case MEDICATION_HISTORY_SEGMENT_INDEX :
            let storyboard = UIStoryboard(name: "MedicationHistory", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("MedicationHistory")
            self.presentViewController(vc, animated: true, completion: nil)
            break
            
        case BNF_SEGMENT_INDEX :
            break
        default :
            break
        }
    }
}
