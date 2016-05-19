//
//  DCInterventionSingleLineExpansionViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 18/05/16.
//
//

import UIKit

class DCInterventionSingleLineExpansionViewController: UIViewController {

    @IBOutlet weak var intervensionDetailsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DETAILS_TEXT
        self.intervensionDetailsTableView.rowHeight = UITableViewAutomaticDimension
        self.intervensionDetailsTableView.estimatedRowHeight = CGFloat(NORMAL_CELL_HEIGHT)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.intervensionDetailsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Tableview Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 3
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
        
            let cell = intervensionDetailsTableView.dequeueReusableCellWithIdentifier(RESOLVE_INTERVENTION_CELL) as? DCInterventionAddOrResolveTableCell
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
