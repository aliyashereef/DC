//
//  DCAddNewDoseAndTimeViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 05/01/16.
//
//

import UIKit

typealias NewDosageEntered = String? -> Void

class DCAddNewDoseAndTimeViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {

    var detailType : AddNewType = eAddNewDose
    var newDosageEntered: NewDosageEntered = { value in }
    @IBOutlet weak var newDosageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBarItems()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBarItems() {
        
            // Configure bar buttons for Add new.
            let cancelButton: UIBarButtonItem = UIBarButtonItem(title: CANCEL_BUTTON_TITLE, style: .Plain, target: self, action: "cancelButtonPressed")
            self.navigationItem.leftBarButtonItem = cancelButton
            let doneButton: UIBarButtonItem = UIBarButtonItem(title: DONE_BUTTON_TITLE, style: .Plain, target: self, action: "doneButtonPressed")
            self.navigationItem.rightBarButtonItem = doneButton
            if (detailType == eAddNewDose) {
                self.navigationItem.title = ADD_NEW_TITLE
                self.title = ADD_NEW_TITLE
            } else {
                self.navigationItem.title = ADD_NEW_TIME
                self.title = ADD_NEW_TIME
            }
    }
    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if detailType == eAddNewDose {
        let newDosageCell : DCAddNewDoseAndTimeTableViewCell? = tableView.dequeueReusableCellWithIdentifier(ADD_NEW_VALUE_CELL_ID) as? DCAddNewDoseAndTimeTableViewCell
        return newDosageCell!
        } else {
            let newTimeCell : DCAddNewDoseAndTimeTableViewCell? = newDosageTableView.dequeueReusableCellWithIdentifier(ADD_NEW_TIME_CELL_ID) as? DCAddNewDoseAndTimeTableViewCell
            return newTimeCell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (detailType == eAddNewDose) {
        return 44
        } else {
            return 216
        }
    }

    // MARK: - Action Methods
    
    func validateNewDosageValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        return isNumeric && NSString(string: value).floatValue < 10000
    }
    
    func cancelButtonPressed() {
        
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed() {
        
        if detailType == eAddNewDose {
            if let dosageCell: DCAddNewDoseAndTimeTableViewCell = newDosageTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? DCAddNewDoseAndTimeTableViewCell {
                if (dosageCell.newDosageTextField.text! != "" && validateNewDosageValue(dosageCell.newDosageTextField.text!)) {
                    self.newDosageEntered(dosageCell.newDosageTextField.text!)
                    self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
                }
            }
        } else {
            if let dosageCell: DCAddNewDoseAndTimeTableViewCell = newDosageTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? DCAddNewDoseAndTimeTableViewCell {
                let newTime = DCDateUtility.dateInCurrentTimeZone(dosageCell.timePicker.date)
                let newTimeString = DCDateUtility.timeStringInTwentyFourHourFormat(newTime)
                self.newDosageEntered(newTimeString)
                //delegate?.userDidSelectValue(DCDateUtility.timeStringInTwentyFourHourFormat(newTime))
                self.navigationController!.dismissViewControllerAnimated(true, completion:nil)
            }
        }
    }

}
