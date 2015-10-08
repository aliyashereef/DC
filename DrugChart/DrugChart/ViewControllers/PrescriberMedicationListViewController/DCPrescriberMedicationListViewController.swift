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
            
            self.fillInMedicationDetailsInTableCell(medicationCell!, atIndexPath: indexPath)
            self.addAdministerStatusViewsToTableCell(medicationCell!, forMedicationScheduleDetails: medicationScheduleDetails, atIndexPath: indexPath)
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
    
    func addAdministerStatusViewsToTableCell(medicationCell: PrescriberMedicationTableViewCell, forMedicationScheduleDetails medicationSchedule:DCMedicationScheduleDetails,
        atIndexPath indexPath:NSIndexPath) {
           
            // method adds the administration status views to the table cell.
            //TODO: UIView instances to be replaced with DCMedicationAdministrationStatusView instances.
            var x :CGFloat = 0
            let y :CGFloat = 0
            let height = medicationCell.frame.size.height, width = (self.view.frame.size.width - medicationCell.medicineDetailHolderView.frame.size.width - 5) / 5
            print("the height: %d width: %d", height, width)
            var viewPosition : CGFloat
            for (viewPosition = 0; viewPosition < 5; viewPosition++) {
                // here add the subviews for status views with correspondng medicationSlot values.
                let aCenterSampleView: UIView = UIView(frame: CGRectMake(x, y, width, height))
                aCenterSampleView.backgroundColor = UIColor.redColor()
                medicationCell.masterMedicationAdministerDetailsView.addSubview(aCenterSampleView)
                
                let aLeftSampleView: UIView = UIView(frame: CGRectMake(x, y, width, height))
                aLeftSampleView.backgroundColor = UIColor.yellowColor()
                medicationCell.leftMedicationAdministerDetailsView.addSubview(aLeftSampleView)
                
                let aRightSampleView: UIView = UIView(frame: CGRectMake(x, y, width, height))
                aRightSampleView.backgroundColor = UIColor.greenColor()
                medicationCell.leftMedicationAdministerDetailsView.addSubview(aRightSampleView)
                
                x = (viewPosition + 1) + (viewPosition + 1) * width
                
            }
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
