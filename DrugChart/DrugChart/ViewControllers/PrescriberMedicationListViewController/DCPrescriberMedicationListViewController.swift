//
//  DCPrescriberMedicationListViewController.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 06/10/15.
//
//

import UIKit

let CELL_IDENTIFIER = "prescriberIdentifier"

@objc class DCPrescriberMedicationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var medicationTableView: UITableView?
    var displayMedicationListArray : NSMutableArray = []
    var currentWeekDatesArray : NSMutableArray = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return displayMedicationListArray.count
        return displayMedicationListArray.count
    }
    
    func tableView(_tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            var medicationCell = _tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? PrescriberMedicationTableViewCell
            if medicationCell == nil {
                medicationCell = PrescriberMedicationTableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CELL_IDENTIFIER)
            }
            let medicationScheduleDetails: DCMedicationScheduleDetails = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
            print("the medicine is: %@", medicationScheduleDetails.name)
            
            self.fillInMedicationDetailsInTableCell(medicationCell!, atIndexPath: indexPath)
            let rowDisplayMedicationSlotsArray = self.prepareMedicationSlotsForDisplayInCellFromScheduleDetails(medicationScheduleDetails)
            var index : NSInteger = 0
            for ( index = 0; index < rowDisplayMedicationSlotsArray.count; index++) {
                
                
                let statusView : DCMedicationAdministrationStatusView = self.addAdministerStatusViewsToTableCell(medicationCell!, forMedicationSlotDictionary: rowDisplayMedicationSlotsArray.objectAtIndex(index) as! NSDictionary,
                    atIndexPath: indexPath,
                    atSlotIndex: index)
                medicationCell?.masterMedicationAdministerDetailsView.addSubview(statusView)
            }
            return medicationCell!
    }
    
    
    // MARK: - Public methods
    
    func reloadMedicationListWithDisplayArray (displayArray: NSMutableArray) {
        
        displayMedicationListArray = displayArray
        medicationTableView?.reloadData()
        
    }
    
    // MARK: - Private methods
    func fillInMedicationDetailsInTableCell(cell: PrescriberMedicationTableViewCell,
        atIndexPath indexPath:NSIndexPath) {
            let medicationCell = cell
            if (displayMedicationListArray.count >= indexPath.item) {
                
                let medicationSchedules = displayMedicationListArray.objectAtIndex(indexPath.item) as! DCMedicationScheduleDetails
                medicationCell.medicineName.text = medicationSchedules.name;
                medicationCell.instructions.text = medicationSchedules.instruction;
                medicationCell.route.text = medicationSchedules.route;
            }
    }
    
//    func addAdministerStatusViewsToTableCell(medicationCell: PrescriberMedicationTableViewCell, forMedicationScheduleDetails medicationSchedule:DCMedicationScheduleDetails,
//        atIndexPath indexPath:NSIndexPath) {
//           
//            // method adds the administration status views to the table cell.
//            //TODO: UIView instances to be replaced with DCMedicationAdministrationStatusView instances.
//            var x :CGFloat = 0
//            let y :CGFloat = 0
//            let height = medicationCell.frame.size.height, width = (self.view.frame.size.width - medicationCell.medicineDetailHolderView.frame.size.width - 5) / 5
//            print("the height: %d width: %d", height, width)
//            var viewPosition : CGFloat
//            for (viewPosition = 0; viewPosition < 5; viewPosition++) {
//                // here add the subviews for status views with correspondng medicationSlot values.
//                let aCenterSampleView: UIView = UIView(frame: CGRectMake(x, y, width, height))
//                aCenterSampleView.backgroundColor = UIColor.redColor()
//                medicationCell.masterMedicationAdministerDetailsView.addSubview(aCenterSampleView)
//                
//                let aLeftSampleView: UIView = UIView(frame: CGRectMake(x, y, width, height))
//                aLeftSampleView.backgroundColor = UIColor.yellowColor()
//                medicationCell.leftMedicationAdministerDetailsView.addSubview(aLeftSampleView)
//                
//                let aRightSampleView: UIView = UIView(frame: CGRectMake(x, y, width, height))
//                aRightSampleView.backgroundColor = UIColor.greenColor()
//                medicationCell.leftMedicationAdministerDetailsView.addSubview(aRightSampleView)
//                
//                x = (viewPosition + 1) + (viewPosition + 1) * width
//                
//            }
//    }
    
    func addAdministerStatusViewsToTableCell(medicationCell: PrescriberMedicationTableViewCell, forMedicationSlotDictionary slotDictionary:NSDictionary,
        atIndexPath indexPath:NSIndexPath,
        atSlotIndex tag:NSInteger) -> DCMedicationAdministrationStatusView {
            
            let slotWidth = DCUtility.getMainWindowSize().width
            let viewWidth = (slotWidth - 300)/5
            let xValue : CGFloat = CGFloat(tag) * viewWidth + CGFloat(tag) + 1;
            let viewFrame = CGRectMake(xValue, 0, viewWidth, 78.0)
            let statusView : DCMedicationAdministrationStatusView = DCMedicationAdministrationStatusView(frame: viewFrame)
            statusView.tag = tag
            print("the date is:%@ \nand tag is %d", statusView, tag)
            print("the crashed index path is: %d", indexPath.item)
            
            statusView.weekdate = currentWeekDatesArray.objectAtIndex(tag) as? NSDate
            statusView.currentIndexPath = indexPath
            statusView.backgroundColor = UIColor.whiteColor()
            statusView.updateAdministrationStatusViewWithMedicationSlotDictionary(slotDictionary)
            return statusView
    }
    
    func prepareMedicationSlotsForDisplayInCellFromScheduleDetails (medicationScheduleDetails: DCMedicationScheduleDetails) -> NSMutableArray {
        
        var count = 0, weekDays = 5
        let medicationSlotsArray: NSMutableArray = []
        while (count < weekDays) {
            let slotsDictionary = NSMutableDictionary()
            if count < currentWeekDatesArray.count {
                let date = currentWeekDatesArray.objectAtIndex(count)
                let formattedDateString = DCDateUtility.convertDate(date as! NSDate, fromFormat: DEFAULT_DATE_FORMAT,
                    toFormat: SHORT_DATE_FORMAT)
                let predicateString = NSString(format: "medDate contains[cd] '%@'",formattedDateString)
                let predicate = NSPredicate(format: predicateString as String)
                //TODO: check if this is right practise. If not change this checks accordingly.
                if let scheduleArray = medicationScheduleDetails.timeChart {
                    if let slotDetailsArray : NSArray = scheduleArray.filteredArrayUsingPredicate(predicate) {
                        if slotDetailsArray.count != 0 {
                            if let medicationSlotArray = slotDetailsArray.objectAtIndex(0).valueForKey(MED_DETAILS) {
                                slotsDictionary.setObject(medicationSlotArray, forKey: PRESCRIBER_TIME_SLOTS)
                            }
                        }
                    }
                }
                slotsDictionary.setObject(NSNumber (integer: count + 1), forKey: PRESCRIBER_SLOT_VIEW_TAG)
                medicationSlotsArray.addObject(slotsDictionary)
                count++
            }
        }
        return medicationSlotsArray
    }
}
