//
//  DCInterventionDetailsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 27/04/16.
//
//

import UIKit

class DCInterventionDetailsViewController: UIViewController {
    
    @IBOutlet weak var interventionTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("INTERVENTION_DETAILS", comment: "")
        self.interventionTableView.rowHeight = UITableViewAutomaticDimension
        self.interventionTableView.estimatedRowHeight = CGFloat(NORMAL_CELL_HEIGHT)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.interventionTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Tableview Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch(indexPath.section)
        {
        case eZerothSection.rawValue:
            return UITableViewAutomaticDimension
        default:
            return UITableViewAutomaticDimension
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == eZerothSection.rawValue {
            let cell = interventionTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_CELL) as? DCInterventionAddOrResolveTableCell
            switch indexPath.row {
            case RowCount.eZerothRow.rawValue:
                cell!.actionNameTitleLabel.text = NSLocalizedString("CREATED_BY", comment: "")
                cell!.actionDateTitleLabel.text = NSLocalizedString("INTERVENTION_ADDED", comment: "")
            case RowCount.eFirstRow.rawValue:
                cell!.actionNameTitleLabel.text = NSLocalizedString("EDITED_BY" , comment: "")
                cell!.actionDateTitleLabel.text = NSLocalizedString("INTERVENTION_EDITED", comment: "")
            case RowCount.eSecondRow.rawValue:
                cell!.actionNameTitleLabel.text = NSLocalizedString("RESOLVED_BY", comment: "")
                cell!.actionDateTitleLabel.text = NSLocalizedString("INTERVENTION_RESOLVED", comment: "")
            default:
                break
            }
            return cell!
        } else {
            let cell = interventionTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_DETAILS_SINGLE_CELL_ID) as? DCInterventionAddOrResolveTableCell
            cell?.accessoryType = .DisclosureIndicator
            let descriptionString : NSMutableAttributedString = NSMutableAttributedString(string:NSLocalizedString("ADDED_INTERVENTION_SINGLE_LINE_DETAIL", comment: ""))
            descriptionString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(colorLiteralRed: 115/255, green: 115/255, blue: 115/255, alpha: 1), range: NSMakeRange(0, descriptionString.length))
            
            let doctorNameString: NSMutableAttributedString = NSMutableAttributedString(string:NSLocalizedString("DOCTOR_NAME", comment: ""))
            doctorNameString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(colorLiteralRed: 70/255, green: 70/255, blue: 70/255, alpha: 1), range: NSMakeRange(0, doctorNameString.length))
            
            descriptionString.appendAttributedString(doctorNameString);
            cell!.interventionDetailsSingleLabel.attributedText = descriptionString
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section != eZerothSection.rawValue {
            self.displayExpandedInterventionDetails(indexPath)
        }
    }
    
    func displayExpandedInterventionDetails(indexPath : NSIndexPath) {
        
        let interventionDetailsViewController = UIStoryboard(name: SUMMARY_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(INTERVENTION_DETAILS_EXPANSION_SB_ID) as? DCInterventionSingleLineExpansionViewController
        self.navigationController?.pushViewController(interventionDetailsViewController!, animated: true)
    }
}
