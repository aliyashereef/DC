//
//  DCPatientListingViewController.swift
//  DrugChart
//
//  Created by aliya on 05/10/15.
//
//

import Foundation
import UIKit

let overDueTitle : NSString = "MEDICATION - OVERDUE"
let immediateTitle : NSString = "MEDICATION - IMMEDIATE"
let notImmediateTitle : NSString = "MEDICATION - UPCOMING"
let searchBarHeight : NSInteger = 44
let fullWindowRowHeight : CGFloat = 115
let oneThirdWindowRowHeight : CGFloat = 147
let sectionHeaderHeight : CGFloat = 60
let searchText : NSString = "Search"

enum SectionValue : NSInteger {
    case eOverDue = 0
    case eImmediate
    case eNotImmediate
}

class DCPatientListingViewController: DCBaseViewController ,UITableViewDataSource, UITableViewDelegate ,WardSelectionDelegate, UISearchBarDelegate {
    
    @IBOutlet var patientListTableView: UITableView!

    var viewTitle : NSString!
    var isSearching : Bool = false
    var selectedIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    var refreshControl :UIRefreshControl!

    var patientListArray : NSMutableArray = []
    var sortedPatientListArray : NSMutableArray = []
    var sortedSearchListArray : NSMutableArray = []
    var wardsListArray : NSMutableArray = []
    var bedsArray : NSMutableArray = []
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCompletePatientDetails()
        configureNavigationBar()
        addSearchBar()
        addRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        cancelSearching()
        configureSearchBarViewProperties()
        self.patientListTableView.reloadData()
        self.messageLabel.hidden = true
        patientListTableView.tableFooterView = UIView(frame: CGRectZero)
        patientListTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        patientListTableView.reloadData()
    }
    //MARK: View methods
    //Configuring view properties
    
    func configureSearchBarViewProperties() {
        if isSearching {
            patientListTableView.setContentOffset(CGPointZero, animated: false)
            patientListTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        } else {
            searchBar.text = EMPTY_STRING
            self.performSelector("hideSearchBar", withObject:nil , afterDelay:0.0)
        }
        self.viewDidLayoutSubviews()
    }
    
    func configureNavigationBar() {
        setNavigationBarTitle()
        let wardsButton : UIBarButtonItem = UIBarButtonItem(title:"Wards", style: UIBarButtonItemStyle.Plain, target: self, action: "presentWardsListView:")
        let graphicViewButton : UIBarButtonItem = UIBarButtonItem(image:  UIImage(named: "graphicDisplayImage"), style: UIBarButtonItemStyle.Plain, target: self, action: "presentGraphicalWardsView")
        self.navigationItem.leftBarButtonItem = wardsButton
        self.navigationItem.rightBarButtonItem = graphicViewButton
    }
    
    func setNavigationBarTitle () {
        
        let label : UILabel = UILabel()
        label.font = UIFont.boldSystemFontOfSize(18)
        label.text = viewTitle! as String
        self.navigationItem.title = label.text
    }
    
    //MARK: Search Bar configuration
    
    func hideSearchBar () {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        patientListTableView.setContentOffset(CGPointMake(0,-20), animated: false)
    }
    
    func addSearchBar () {
        
        searchBar.searchBarStyle = UISearchBarStyle.Default
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        searchBar.placeholder = searchText as String
    }
    
    func cancelSearching () {
        
        isSearching = false
        searchBar.text = EMPTY_STRING
        searchBar.resignFirstResponder()
        
    }
    
    //MARK: Refresh control configuration
    
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl.init()
        refreshControl.addTarget(self, action:"refreshControlAction", forControlEvents: UIControlEvents.ValueChanged)
        if refreshControl.isDescendantOfView(self.view) {
            
        } else {
            self.patientListTableView.addSubview(refreshControl)
        }
    }
    
    func refreshControlAction () {
        
        cancelSearching()
        fetchPatientDetails()
    }
    
    //MARK: Table view methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCountForPatientTableView()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViewForSection(section)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
            
            return oneThirdWindowRowHeight
        } else {
            return fullWindowRowHeight
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCountForSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : DCPatientListingCell = (tableView.dequeueReusableCellWithIdentifier("PatientCell") as? DCPatientListingCell)!
        cell.layoutMargins = UIEdgeInsetsZero
        let patient : DCPatient  = patientForTableCellAtIndexPath(indexPath)
        cell.populatePatientCellWithPatientDetails(patient)
        return cell
    }
    
    //MARK: - Table view Delegate Implementation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        goToPrescriberMedicationViewController(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func sectionTitleForSection( section :NSInteger ) -> NSString {
        //get section title
        var sectionTitle : String = EMPTY_STRING
        let contentArray : NSArray = isSearching ? self.sortedSearchListArray : sortedPatientListArray

        let overDueDictionary : NSDictionary = contentArray.objectAtIndex(0) as! NSDictionary
        let overDueArray : NSArray = overDueDictionary.valueForKey(OVERDUE_KEY) as! NSArray
        
        let immediateDictionary : NSDictionary = contentArray.objectAtIndex(1) as! NSDictionary
        let immediateArray : NSArray = immediateDictionary.valueForKey(IMMEDIATE_KEY) as! NSArray
        
        let nonImmediateDictionary : NSDictionary = contentArray.objectAtIndex(2) as! NSDictionary
        let nonImmediateArray : NSArray = nonImmediateDictionary.valueForKey(NOT_IMMEDIATE_KEY) as! NSArray
        if let sectionValue = SectionValue(rawValue: section) {
            switch sectionValue {
            case .eOverDue:
                if (overDueArray.count > 0) {
                    sectionTitle = overDueTitle as String
                } else {
                    if (immediateArray.count > 0) {
                        sectionTitle = immediateTitle as String
                    } else {
                        sectionTitle = notImmediateTitle as String
                    }
                }
                break
            case .eImmediate:
                if (immediateArray.count > 0) {
                    sectionTitle = immediateTitle as String
                } else {
                    sectionTitle = notImmediateTitle as String
                }
                break
            case .eNotImmediate:
                if (nonImmediateArray.count > 0) {
                    sectionTitle = notImmediateTitle as String
                }
                break
            }
        }
        return sectionTitle
    }
    
    func goToPrescriberMedicationViewController(indexPath :NSIndexPath ) {
        
        let menuViewController : DCPatientMenuViewController? = UIStoryboard(name: PATIENT_MENU_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(PATIENT_MENU_VIEW_CONTROLLER_SB_ID) as? DCPatientMenuViewController
        
        let patient : DCPatient = patientForTableCellAtIndexPath(indexPath)
        menuViewController?.patient = patient
        self.navigationController!.showViewController(menuViewController!,sender: self)
    }

    // Private Methods
    
    func sortedArray (listArray :NSMutableArray) -> NSMutableArray {
        var sortedArray : NSMutableArray = []
        let helper : DCPatientDetailsHelper = DCPatientDetailsHelper()
        helper.patientsListArray = listArray
        sortedArray = helper.categorizePatientListBasedOnEmergency(listArray)
        return sortedArray
    }

    //MARK: Private methods, Table view helper methods
    
    func headerViewForSection (section:NSInteger) -> UIView {
        
        let headerView : UIView = UIView.init()
        let contentArray : NSArray = isSearching ? self.sortedSearchListArray : sortedPatientListArray
        if contentArray.count > 0 {
            let sectionTitle : NSString = sectionTitleForSection(section)
            let headerLabel: UILabel = UILabel.init(frame: CGRectMake(20, 35, 320, 20))
            headerLabel.backgroundColor = UIColor.clearColor()
            headerLabel.textColor = UIColor(forHexString: "#6D6D72")
            headerLabel.font = UIFont.boldSystemFontOfSize(14)
            headerLabel.text = sectionTitle as String
            headerView.backgroundColor = UIColor(forHexString: "#EFEFF6")
            headerView.addSubview(headerLabel)
        }
        return headerView
    }
    
    func sectionCountForPatientTableView() -> NSInteger {
        let contentArray : NSArray = isSearching ? self.sortedSearchListArray : sortedPatientListArray

        let overDueDictionary : NSDictionary = contentArray.objectAtIndex(0) as! NSDictionary
        let overDueArray : NSArray = overDueDictionary.valueForKey(OVERDUE_KEY) as! NSArray
        
        let immediateDictionary : NSDictionary = contentArray.objectAtIndex(1) as! NSDictionary
        let immediateArray : NSArray = immediateDictionary.valueForKey(IMMEDIATE_KEY) as! NSArray
        
        let nonImmediateDictionary : NSDictionary = contentArray.objectAtIndex(2) as! NSDictionary
        let nonImmediateArray : NSArray = nonImmediateDictionary.valueForKey(NOT_IMMEDIATE_KEY) as! NSArray
        
        var sectionCount : Int = 0
        if overDueArray.count > 0 {
            sectionCount++
        }
        if immediateArray.count > 0 {
            sectionCount++
        }
        if nonImmediateArray.count > 0 {
            sectionCount++
        }
        return sectionCount
    }

    func rowCountForSection(section:NSInteger) -> NSInteger {
        let contentArray : NSArray = isSearching ? self.sortedSearchListArray : sortedPatientListArray

        let overDueDictionary : NSDictionary = contentArray.objectAtIndex(0) as! NSDictionary
        let overDueArray : NSArray = overDueDictionary.valueForKey(OVERDUE_KEY) as! NSArray
        
        let immediateDictionary : NSDictionary = contentArray.objectAtIndex(1) as! NSDictionary
        let immediateArray : NSArray = immediateDictionary.valueForKey(IMMEDIATE_KEY) as! NSArray
        
        let nonImmediateDictionary : NSDictionary = contentArray.objectAtIndex(2) as! NSDictionary
        let nonImmediateArray : NSArray = nonImmediateDictionary.valueForKey(NOT_IMMEDIATE_KEY) as! NSArray
        if let sectionValue = SectionValue(rawValue: section) {
            switch sectionValue {
            case .eOverDue:
                if (overDueArray.count > 0) {
                    return overDueArray.count
                } else if (immediateArray.count > 0) {
                    return immediateArray.count
                } else {
                    return nonImmediateArray.count
                }
            case .eImmediate:
                if (immediateArray.count > 0) {
                    return immediateArray.count
                } else {
                    return nonImmediateArray.count
                }
            case .eNotImmediate:
                if (nonImmediateArray.count > 0) {
                    return nonImmediateArray.count
                }
                break
            }
        }
        return 0
    }

    func patientForTableCellAtIndexPath( indexPath: NSIndexPath ) -> DCPatient {

        let contentArray : NSArray = isSearching ? self.sortedSearchListArray : sortedPatientListArray

        let overDueDictionary : NSDictionary = contentArray.objectAtIndex(0) as! NSDictionary
        let overDueArray : NSArray = overDueDictionary.valueForKey(OVERDUE_KEY) as! NSArray
        
        let immediateDictionary : NSDictionary = contentArray.objectAtIndex(1) as! NSDictionary
        let immediateArray : NSArray = immediateDictionary.valueForKey(IMMEDIATE_KEY) as! NSArray
        
        let nonImmediateDictionary : NSDictionary = contentArray.objectAtIndex(2) as! NSDictionary
        let nonImmediateArray : NSArray = nonImmediateDictionary.valueForKey(NOT_IMMEDIATE_KEY) as! NSArray
        if let sectionValue = SectionValue(rawValue: indexPath.section) {
            switch sectionValue {
            case .eOverDue:
                if (overDueArray.count > 0) {
                    return overDueArray.objectAtIndex(indexPath.row) as! DCPatient
                } else if (immediateArray.count > 0) {
                    return immediateArray.objectAtIndex(indexPath.row) as! DCPatient
                } else {
                    return nonImmediateArray.objectAtIndex(indexPath.row) as! DCPatient
                }
            case .eImmediate:
                if (immediateArray.count > 0) {
                    return immediateArray.objectAtIndex(indexPath.row) as! DCPatient
                } else {
                    return nonImmediateArray.objectAtIndex(indexPath.row) as! DCPatient
                }
            case .eNotImmediate:
                if (nonImmediateArray.count > 0) {
                    return nonImmediateArray.objectAtIndex(indexPath.row) as! DCPatient
                }
            }
        }
        return DCPatient.init()
    }
    
    //UIBarButtomItem selection methods
    
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
    
    func presentGraphicalWardsView () {
        
        var wardsGraphicalDisplayViewController : DCWardsGraphicalDisplayViewController
        wardsGraphicalDisplayViewController = self.storyboard!.instantiateViewControllerWithIdentifier(WARDS_GRAPHICAL_DISPLAY_VC_SB_ID) as! DCWardsGraphicalDisplayViewController
        wardsGraphicalDisplayViewController.bedsArray = self.bedsArray
        wardsGraphicalDisplayViewController.wardDisplayed = self.wardsListArray.objectAtIndex(selectedIndexPath.row) as! DCWard
        
        let navigationController = UINavigationController(rootViewController: wardsGraphicalDisplayViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    //MARK: ward selection delegate
    
    func newWardSelected(row: NSInteger) {
        cancelSearching()
        selectedIndexPath = NSIndexPath.init(forRow: row, inSection: 0)
        fetchPatientDetails()
    }
    
    //MARK: Search Bar Delegate Methods 
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        cancelSearching()
        patientListTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            isSearching = true
            searchPatientListWithText(searchText)
        } else {
            cancelSearching()
            patientListTableView.reloadData()
        }
    }
    
    // search functionality helper methods
    
    func searchPatientListWithText( searchText : NSString) {
        let patientNameString : NSString =  NSString(format: "patientName contains[c] '%@'", searchText)
        let namePredicate : NSPredicate = NSPredicate(format: patientNameString as String)
        let patientIdString : NSString =  NSString(format: "patientNumber contains[c] '%@'", searchText)
        let idPredicate : NSPredicate = NSPredicate(format: patientIdString as String)
        let searchPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate,idPredicate])
        let searchResult : NSArray  = patientListArray.filteredArrayUsingPredicate(searchPredicates)
        self.sortedSearchListArray = sortedArray( searchResult.mutableCopy() as! NSMutableArray)
        patientListTableView.reloadData()
    }
    
    // fetch patient details
    
    func getCompletePatientDetails() {
        let helper : DCPatientDetailsHelper = DCPatientDetailsHelper()
        helper.patientsListArray = self.patientListArray
        helper.setBedsArrayToWard(wardsListArray.objectAtIndex(selectedIndexPath.row) as! DCWard) { (error, array, bedsArray) -> Void in
            if error == nil {
                self.patientListArray = array as NSMutableArray
                self.bedsArray = bedsArray as NSMutableArray
                self.sortedPatientListArray = self.sortedArray(self.patientListArray)
                self.patientListTableView.reloadData()
                self.patientListTableView.hidden = false
            } else {
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func fetchPatientDetails () {
        let helper : DCPatientDetailsHelper = DCPatientDetailsHelper()
        self.activityIndicator.startAnimating()
        helper.fetchPatientsInWard(wardsListArray.objectAtIndex(selectedIndexPath.row) as! DCWard) { (error, array) -> Void in
            self.viewTitle =  self.wardsListArray.objectAtIndex(self.selectedIndexPath.row).wardName as NSString
            if error == nil {
                self.patientListArray = array as NSMutableArray
                self.configureNavigationBar()
                self.getCompletePatientDetails()
                self.messageLabel.hidden = true
            } else {
                // we created a error with code 100 for the patient list empty senario
                if error.code == 100 {
                    self.patientListTableView.hidden = true
                    self.setNavigationBarTitle()
                    self.navigationItem.rightBarButtonItem?.enabled = false
                    self.messageLabel.hidden = false
                } else {
                        self.displayAlertWithTitle(NSLocalizedString("ERROR", comment: ""), message:NSLocalizedString("FETCH_FAILED", comment: ""))
                }
                self.activityIndicator.stopAnimating()
            }
            self.refreshControl.endRefreshing()
        }
    }

}
