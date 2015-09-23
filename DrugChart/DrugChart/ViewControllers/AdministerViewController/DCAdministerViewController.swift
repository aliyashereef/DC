//
//  AdministerViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/22/15.
//
//

import UIKit

let ADMINISTERED_SECTION_COUNT : NSInteger = 4
let OMITTED_SECTION_COUNT : NSInteger = 3
let INITIAL_SECTION_ROW_COUNT : NSInteger = 2
let STATUS_ROW_COUNT : NSInteger = 1
let ADMINISTERED_SECTION_ROW_COUNT : NSInteger = 4
let OMITTED_OR_REFUSED_SECTION_ROW_COUNT : NSInteger = 1
let NOTES_SECTION_ROW_COUNT : NSInteger = 1
let INITIAL_SECTION_HEIGHT : CGFloat = 0.0
let TABLEVIEW_DEFAULT_SECTION_HEIGHT : CGFloat = 40.0


class DCAdministerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var administerTableView: UITableView!
    
    var medicationSlot : DCMedicationSlot?
    var medicationDetails : DCMedicationScheduleDetails?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewElements()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func configureViewElements () {
        
        administerTableView!.layoutMargins = UIEdgeInsetsZero
        administerTableView!.separatorInset = UIEdgeInsetsZero
    }
    
    func configureTableCellAtIndexPath(indexPath : NSIndexPath) -> (DCAdministerCell){
        
        let administerCell : DCAdministerCell = (administerTableView.dequeueReusableCellWithIdentifier(ADMINISTER_CELL_ID) as? DCAdministerCell)!
        administerCell.layoutMargins = UIEdgeInsetsZero
        switch indexPath.section {
        case 0:
            let dateString : String
            if indexPath.row == 0 {
                if let date = medicationSlot?.time {
                    dateString = DCDateUtility.convertDate(date, fromFormat: DEFAULT_DATE_FORMAT, toFormat: "d LLLL yyyy")
                } else {
                    dateString = EMPTY_STRING
                }
                administerCell.titleLabel.text = dateString
            }
            break;
        default:
            break;
        }
        return administerCell
    }
    
    // MARK: TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (medicationSlot?.status == ADMINISTERED || medicationSlot?.status == REFUSED || medicationSlot?.status == nil){
            return ADMINISTERED_SECTION_COUNT;
        } else if (medicationSlot?.status == OMITTED) {
            return OMITTED_SECTION_COUNT;
        }
        return ADMINISTERED_SECTION_COUNT;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return INITIAL_SECTION_ROW_COUNT
        case 1:
            return STATUS_ROW_COUNT
        case 2:
            if (medicationSlot?.status == OMITTED || medicationSlot?.status == REFUSED) {
                return OMITTED_OR_REFUSED_SECTION_ROW_COUNT;
            } else {
                return ADMINISTERED_SECTION_ROW_COUNT;
            }
        case 3:
            return NOTES_SECTION_ROW_COUNT
        default:
            break;
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let administerCell : DCAdministerCell = configureTableCellAtIndexPath(indexPath)
        return administerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return (section == 0) ? INITIAL_SECTION_HEIGHT : TABLEVIEW_DEFAULT_SECTION_HEIGHT
    }
}
