//
//  DCWarningsListViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/15/15.
//
//

import UIKit

let ROW_HEIGHT : CGFloat = 80.0
let ROW_OFFSET_VALUE : CGFloat = 25.0
let INITIAL_INDEX = 0
let SECOND_INDEX = 1
let NAVIGATION_BAR_HEIGHT_WITH_STATUS_BAR : CGFloat = 64.0
let NAVIGATION_BAR_HEIGHT_NO_STATUS_BAR : CGFloat = 44.0

@objc public protocol WarningsDelegate {
    
    func overrideReasonSubmitted(reason : String)
}

@objc class DCWarningsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddMedicationDetailDelegate {
    
    @IBOutlet weak var warningsTableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var warningsArray = [Dictionary<String, AnyObject>]()
    var severeArray : AnyObject?
    var mildArray : AnyObject?
    var overiddenReason : NSString?
    var loadOverideView : Bool? = false
    var delegate: WarningsDelegate?
    
    
    // MARK: Life Cycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements();
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        warningsTableView!.reloadData()
        // this is set to adjust the bottom constraint, view doesnot move on to its actual height initially
        tableHeight?.constant = DCUtility.mainWindowSize().height - 64
        warningsTableView.layoutSubviews()
    }
        
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if let navigationBar = self.navigationController?.navigationBar {
            var frame = navigationBar.frame
            if (appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow) {
                frame.size.height = NAVIGATION_BAR_HEIGHT_WITH_STATUS_BAR
            } else {
                frame.size.height = NAVIGATION_BAR_HEIGHT_NO_STATUS_BAR
            }
            navigationBar.frame = frame
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Public Methods
    
    func populateWarningsListWithWarnings(warnings : [Dictionary<String, AnyObject>], showOverrideView : Bool)  {
        
        warningsArray  = warnings;
        severeArray = warningsArray[INITIAL_INDEX][SEVERE_WARNING]
        mildArray = warningsArray[SECOND_INDEX][MILD_WARNING]
        loadOverideView = showOverrideView
        if loadOverideView == true {
            self.navigationItem.hidesBackButton = true
        }
    }
    
    // MARK: Private Methods
    
    func configureViewElements () {
        
        //configure view parameters
        warningsTableView!.estimatedRowHeight = ROW_HEIGHT
        warningsTableView!.rowHeight = UITableViewAutomaticDimension
        configureNavigationBar();
    }
    
    func configureNavigationBar () {
        
        self.title = NSLocalizedString("WARNINGS", comment: "title")
        if (loadOverideView == true) {
            let overrideButton = UIBarButtonItem (title: OVERRIDE_BUTTON_TITLE, style: .Plain, target: self, action: Selector("overrideButtonPressed:"))
            self.navigationItem.rightBarButtonItem = overrideButton
            let donotUseButton = UIBarButtonItem (title: DONOTUSE_BUTTON_TITLE, style: .Plain, target: self, action: Selector("donotUseDrugAction:"))
            self.navigationItem.leftBarButtonItem = donotUseButton
        }
    }
    
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var sectionCount : NSInteger = 0;
        if warningsArray.count > 0 {
            if severeArray?.count > 0 {
                sectionCount = sectionCount + 1
            }
            if mildArray?.count > 0 {
                sectionCount = sectionCount + 1
            }
        }
        if loadOverideView == false {
            sectionCount++
        }
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loadOverideView == false {
            if section == SectionCount.eZerothSection.rawValue {
                return 1
            } else if section == SectionCount.eFirstSection.rawValue {
                if severeArray?.count > 0 {
                    return severeArray!.count
                } else {
                    if mildArray?.count > 0 {
                        return mildArray!.count
                    }
                }
            } else {
                if mildArray?.count > 0 {
                    return mildArray!.count
                }
            }
        } else {
            if section == SectionCount.eZerothSection.rawValue {
                if severeArray?.count > 0 {
                    return severeArray!.count
                } else {
                    if mildArray?.count > 0 {
                        return mildArray!.count
                    }
                }
            } else {
                if mildArray?.count > 0 {
                    return mildArray!.count
                }
            }
        }
        return RowCount.eZerothRow.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : DCWarningsCell = (tableView.dequeueReusableCellWithIdentifier(WARNINGS_CELL_ID) as? DCWarningsCell)!
        if loadOverideView == false {
            if indexPath.section == SectionCount.eZerothSection.rawValue {
                cell.populateCellWithOverrideReasonObject(overiddenReason!)

            }else if indexPath.section == SectionCount.eFirstSection.rawValue {
                if severeArray?.count > 0 {
                    if let warning = severeArray?[indexPath.row]! as? DCWarning {
                        cell.populateWarningsCellWithWarningsObject(warning)
                    }
                } else {
                    if let warning = mildArray?[indexPath.row]! as? DCWarning {
                        cell.populateWarningsCellWithWarningsObject(warning)
                    }
                }
            } else {
                if let warning = mildArray?[indexPath.row]! as? DCWarning {
                    cell.populateWarningsCellWithWarningsObject(warning)
                }
            }
        } else {
            if indexPath.section == SectionCount.eZerothSection.rawValue {
                if severeArray?.count > 0 {
                    if let warning = severeArray?[indexPath.row]! as? DCWarning {
                        cell.populateWarningsCellWithWarningsObject(warning)
                    }
                } else {
                    if let warning = mildArray?[indexPath.row]! as? DCWarning {
                        cell.populateWarningsCellWithWarningsObject(warning)
                    }
                }
            } else {
                if let warning = mildArray?[indexPath.row]! as? DCWarning {
                    cell.populateWarningsCellWithWarningsObject(warning)
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if loadOverideView == false {
            if section == SectionCount.eZerothSection.rawValue{
                return NSLocalizedString("OVERRIDE REASON", comment: "override reasons title")
            }else if section == SectionCount.eFirstSection.rawValue {
                if severeArray?.count > 0 {
                    return NSLocalizedString("SEVERE", comment: "Severe Warnings title")
                } else {
                    return NSLocalizedString("MILD", comment: "Mild Warnings title")
                }
            } else {
                return NSLocalizedString("MILD", comment: "Mild Warnings title")
            }
        } else {
            if section == SectionCount.eZerothSection.rawValue {
                if severeArray?.count > 0 {
                    return NSLocalizedString("SEVERE", comment: "Severe Warnings title")
                } else {
                    return NSLocalizedString("MILD", comment: "Mild Warnings title")
                }
            } else {
                return NSLocalizedString("MILD", comment: "Mild Warnings title")
            }
        }
    }
        
    // MARK: Action Methods
    
    @IBAction func donotUseDrugAction(sender: AnyObject) {
        
        //don not use the selected drug 
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func overrideButtonPressed(sender: AnyObject) {
        
        //display reason view
        let detailViewController : DCAddMedicationDetailViewController? = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_MEDICATION_DETAIL_STORYBOARD_ID) as? DCAddMedicationDetailViewController
        detailViewController?.delegate = self
        let navigationController : UINavigationController? = UINavigationController(rootViewController: detailViewController!)
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(navigationController!, animated: true, completion: nil)
    }
    
    // MARK : AddMedicationDetailDelegate Methods
    
    func overrideReasonSubmittedInDetailView(reason: String!) {
        
        if let delegate = self.delegate {
            delegate.overrideReasonSubmitted(reason)
        }
    }
}
