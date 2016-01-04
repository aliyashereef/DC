//
//  DCWardsInformationsViewController.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/01/16.
//
//

import UIKit

class DCWardsInformationsViewController: DCBaseViewController, WardSelectionDelegate  {
    
    var viewTitle : NSString!
    
    var patientListArray : NSMutableArray = []
    var sortedPatientListArray : NSMutableArray = []
    var sortedSearchListArray : NSMutableArray = []
    var wardsListArray : NSMutableArray = []
    var bedsArray : NSMutableArray = []
    
    var selectedIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    var graphicalDisplayShown : Bool = false
    var patientListViewController : DCPatientListingViewController?
    var wardsGraphicalDisplayViewController : DCWardsGraphicalDisplayViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.addPatientListingViewController()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPatientListingViewController () {
        
        patientListViewController = self.storyboard!.instantiateViewControllerWithIdentifier(PATIENT_LIST_VIEW_CONTROLLER) as? DCPatientListingViewController
        self.addChildViewController(patientListViewController!)
        patientListViewController!.sortedPatientListArray = self.sortedPatientListArray
        patientListViewController!.patientListArray = self.patientListArray
        patientListViewController!.wardsListArray = self.wardsListArray
        self.view.addSubview(patientListViewController!.view)
        self.view.bringSubviewToFront(patientListViewController!.view)
        
    }
    
    func addWardsGraphicalDisplayViewController() {
        
        var wardsGraphicalDisplayViewController : DCWardsGraphicalDisplayViewController
        wardsGraphicalDisplayViewController = self.storyboard!.instantiateViewControllerWithIdentifier(WARDS_GRAPHICAL_DISPLAY_VC_SB_ID) as! DCWardsGraphicalDisplayViewController
        wardsGraphicalDisplayViewController.bedsArray = self.bedsArray
        wardsGraphicalDisplayViewController.wardDisplayed = self.wardsListArray.objectAtIndex(selectedIndexPath.row) as! DCWard
        
        self.addChildViewController(wardsGraphicalDisplayViewController)
        self.view.addSubview(wardsGraphicalDisplayViewController.view)
        self.view.bringSubviewToFront(wardsGraphicalDisplayViewController.view)
        
    }
    
    func configureNavigationBar() {
        fillNavigationBarTitle()
        let wardsButton : UIBarButtonItem = UIBarButtonItem(title:"Wards", style: UIBarButtonItemStyle.Plain, target: self, action: "presentWardsListView:")
        let graphicViewButton : UIBarButtonItem = UIBarButtonItem(image:  UIImage(named: "graphicDisplayImage"), style: UIBarButtonItemStyle.Plain, target: self, action: "showGraphicalWardsView")
        self.navigationItem.leftBarButtonItem = wardsButton
        self.navigationItem.rightBarButtonItem = graphicViewButton
    }
    
    func fillNavigationBarTitle () {
        
        let label : UILabel = UILabel()
        label.font = UIFont.boldSystemFontOfSize(18)
        label.text = viewTitle! as String
        self.navigationItem.title = label.text
    }
    
    
    func presentWardsListView(sender : UIBarButtonItem) {
        
        // Instantiating the navigation controller to present the popover with preferred content size of the poppver.
        let popoverContent = self.storyboard!.instantiateViewControllerWithIdentifier("WardsListingPopoverViewController") as! DCWardsListingPopoverViewController
        popoverContent.wardsArray = self.wardsListArray
        popoverContent.delegate = self
        let navigationController = UINavigationController(rootViewController: popoverContent)
        navigationController.modalPresentationStyle = .Popover
        
        let popover : UIPopoverPresentationController = navigationController.popoverPresentationController!
        popover.permittedArrowDirections = UIPopoverArrowDirection.Any
        popover.sourceView = self.navigationController?.navigationBar
        popover.barButtonItem = sender as UIBarButtonItem
        self.presentViewController(navigationController, animated:false, completion: nil)
    }
    
    func showGraphicalWardsView () {
        
        if (graphicalDisplayShown) {
            self.view.bringSubviewToFront(patientListViewController!.view)
//            let wardsListImage: UIImage = UIImage(named: "WardsListing")!
//            self.navigationItem.rightBarButtonItem?.setBackgroundImage(wardsListImage, forState: .Normal, barMetrics: .Default)
            graphicalDisplayShown = false
        }
        else {
//            let wardsGraphicalImage: UIImage = UIImage(named: "graphicDisplayImage")!
//            self.navigationItem.rightBarButtonItem?.setBackgroundImage(wardsGraphicalImage, forState: .Normal, barMetrics: .Default)
            if ((wardsGraphicalDisplayViewController) != nil) {
                self.view.bringSubviewToFront(wardsGraphicalDisplayViewController!.view)
            }
            else {
                self.addWardsGraphicalDisplayViewController()
            }
            graphicalDisplayShown = true
        }
    }
    
    //MARK: ward selection delegate
    
    func newWardSelected(row: NSInteger) {
        
        patientListViewController!.cancelSearching()
        selectedIndexPath = NSIndexPath.init(forRow: row, inSection: 0)
        patientListViewController!.selectedIndexPath = NSIndexPath.init(forRow: row, inSection: 0)
        viewTitle = self.wardsListArray.objectAtIndex(self.selectedIndexPath.row).wardName as NSString
        self.navigationItem.title = viewTitle as String
        patientListViewController!.fetchPatientDetails()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
