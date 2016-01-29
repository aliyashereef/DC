//
//  DCWarningsListViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/15/15.
//
//

import UIKit

let SECTION_HEIGHT : CGFloat = 38.0
let ROW_HEIGHT : CGFloat = 80.0
let ROW_OFFSET_VALUE : CGFloat = 25.0
let INITIAL_INDEX = 0
let SECOND_INDEX = 1

@objc public protocol WarningsDelegate {
    
    func overrideReasonSubmitted(reason : String)
}

@objc class DCWarningsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddMedicationDetailDelegate {
    
    @IBOutlet weak var warningsTableView: UITableView?
    
    var warningsArray = [Dictionary<String, AnyObject>]()
    var severeArray : AnyObject?
    var mildArray : AnyObject?
    var loadOverideView : Bool? = false
   // var backButtonText : NSString = EMPTY_STRING
    var delegate: WarningsDelegate?
    
    
    // MARK: Life Cycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements();
        self.edgesForExtendedLayout = UIRectEdge.None
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        warningsTableView!.reloadData()
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
        warningsTableView? .reloadData();
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
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : DCWarningsCell = (tableView.dequeueReusableCellWithIdentifier(WARNINGS_CELL_ID) as? DCWarningsCell)!
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
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return SECTION_HEIGHT
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let warningsHeaderView = NSBundle.mainBundle().loadNibNamed(WARNINGS_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCWarningsHeaderView
        warningsHeaderView?.configureHeaderViewForSection(section)
        return warningsHeaderView
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        if section == SectionCount.eZerothSection.rawValue {
//            return NSLocalizedString("SEVERE", comment: "Severe Warnings title")
//        } else {
//            return NSLocalizedString("MILD", comment: "Mild Warnings title")
//        }
//    }
    
    // MARK: Action Methods
    
    @IBAction func donotUseDrugAction(sender: AnyObject) {
        
        //don not use the selected drug 
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func overrideButtonPressed(sender: AnyObject) {
        
        //display reason view
        let detailViewController : DCAddMedicationDetailViewController? = UIStoryboard(name: ADD_MEDICATION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_MEDICATION_DETAIL_STORYBOARD_ID) as? DCAddMedicationDetailViewController
        detailViewController!.detailType = eOverrideReason
        detailViewController?.delegate = self
        let navigationController : UINavigationController? = UINavigationController(rootViewController: detailViewController!)
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(navigationController!, animated: true, completion: nil)
    }
    
    // MARK : AddMedicationDetailDelegate Methods
    
    func overrideReasonSubmitted(reason: String!) {
        
        if let delegate = self.delegate {
            delegate.overrideReasonSubmitted(reason)
        }
    }
}
