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
    var delegate: WarningsDelegate?
    
    //MARK: Public Methods
    
    func populateWarningsListWithWarnings(warnings : [Dictionary<String, AnyObject>], showOverrideView : Bool)  {
        
        warningsArray  = warnings;
        severeArray = warningsArray[INITIAL_INDEX][SEVERE_WARNING]
        mildArray = warningsArray[SECOND_INDEX][MILD_WARNING]
        loadOverideView = showOverrideView
        if loadOverideView == true {
            self.navigationItem.hidesBackButton = true
        }
//        else {
//            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
//        }
        warningsTableView? .reloadData();
    }
    
    // MARK: Life Cycle Methods
    override func viewDidLoad() {
        
        configureViewElements();
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        warningsTableView!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
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
    
    func calculatedTableCellHeightForWarning(warning : DCWarning) -> CGFloat {
        
        var textHeight : CGFloat = ROW_OFFSET_VALUE
        textHeight += DCUtility.heightValueForText(warning.title, withFont: UIFont.systemFontOfSize(15.0), maxWidth: MAX_WIDTH)
        textHeight += DCUtility.heightValueForText(warning.detail, withFont: UIFont.systemFontOfSize(12.0), maxWidth: MAX_WIDTH)
        return textHeight
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
        
        if section == INITIAL_INDEX {
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
        if indexPath.section == INITIAL_INDEX {
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
        
        var sectionIndex : NSInteger = 0
        if section == INITIAL_INDEX {
            if severeArray?.count > 0 {
                sectionIndex = 0
            } else {
                if mildArray?.count > 0 {
                    sectionIndex = 1
                }
            }
        } else {
            if mildArray?.count > 0 {
                sectionIndex = 1
            }
        }
        let warningsHeaderView = NSBundle.mainBundle().loadNibNamed(WARNINGS_HEADER_VIEW_NIB, owner: self, options: nil)[0] as? DCWarningsHeaderView
        warningsHeaderView?.configureHeaderViewForSection(sectionIndex)
        return warningsHeaderView
    }
    
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
        navigationController?.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.presentViewController(navigationController!, animated: true, completion: nil)
    }
    
    // MARK : AddMedicationDetailDelegate Methods
    
    func overrideReasonSubmitted(reason: String!) {
        
        if let delegate = self.delegate {
            delegate.overrideReasonSubmitted(reason)
        }
    }
}
