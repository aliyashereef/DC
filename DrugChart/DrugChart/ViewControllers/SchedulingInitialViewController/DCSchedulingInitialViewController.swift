//
//  DCSchedulingInitialViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/1/15.
//
//

import UIKit

class DCSchedulingInitialViewController: UIViewController {

    @IBOutlet weak var schedulingTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureNavigationBarItems()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
        self.title = NSLocalizedString("FREQUENCY", comment: "")
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
    }
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }
    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
////        let cell : DCWarningsCell = (tableView.dequeueReusableCellWithIdentifier(WARNINGS_CELL_ID) as? DCWarningsCell)!
////        cell.layoutMargins = UIEdgeInsetsZero
////        if indexPath.section == INITIAL_INDEX {
////            if severeArray?.count > 0 {
////                if let warning = severeArray?[indexPath.row]! as? DCWarning {
////                    cell.populateWarningsCellWithWarningsObject(warning)
////                }
////            } else {
////                if let warning = mildArray?[indexPath.row]! as? DCWarning {
////                    cell.populateWarningsCellWithWarningsObject(warning)
////                }
////            }
////        } else {
////            if let warning = mildArray?[indexPath.row]! as? DCWarning {
////                cell.populateWarningsCellWithWarningsObject(warning)
////            }
////        }
////        return cell
//        return nil
//        
//       
//    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return SECTION_HEIGHT
    }
    

}
