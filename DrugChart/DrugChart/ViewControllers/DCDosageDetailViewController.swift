//
//  DCDosageDetailViewController.swift
//  DrugChart
//
//  Created by Shaheer on 11/12/15.
//
//

import UIKit

let zeroInt : Int = 0
// protocol used for sending data back to Dosage Selection
protocol DataEnteredDelegate: class {
    
    func userDidSelectValue(value: String)
    func newDosageAdded(value : String)
}

class DCDosageDetailViewController: DCBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dosageDetailTableView: UITableView!
    let changeOverItemsArray = ["Days","Doses"]
    var conditionsItemsArray = ["Reduce 50 mg every day"]
    var doseForTimeArray = [String]()
    var detailType : DosageDetailType = eDoseUnit
    var viewTitleForDisplay : NSString = ""
    var previousSelectedValue : NSString = ""
    var selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var dosageDetailsArray = [String]()
    weak var delegate: DataEnteredDelegate? = nil
    let tableviewContentOffset = 44
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
    let thresholdCountForKeyboardAppear : Int = 3
    let thresholdCountForKeyboardDisappear : Int = 9

    override func viewDidLoad() {
        
        super.viewDidLoad()
        dosageDetailTableView.reloadData()
        self.configureNavigationBarItems()
        dosageDetailTableView.keyboardDismissMode = .OnDrag
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        var sectionValue : Int = 1
        if dosageDetailsArray.count == 0 && self.detailType != eAddDoseForTime{
            sectionValue = 0
        } else {
            sectionValue = 1
        }
        if let dosageCell: DCDosageDetailTableViewCell = dosageDetailTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: sectionValue)) as? DCDosageDetailTableViewCell{
            if (dosageCell.addNewDosageTextField.text! != "" && validateNewDosageValue(dosageCell.addNewDosageTextField.text!)) {
                self.previousSelectedValue = dosageCell.addNewDosageTextField.text!
                if self.detailType == eAddDoseForTime {
                    if !self.doseForTimeArray.contains(dosageCell.addNewDosageTextField.text!) {
                        self.doseForTimeArray.append(dosageCell.addNewDosageTextField.text!)
                        self.doseForTimeArray =  self.doseForTimeArray.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                        self.delegate?.newDosageAdded(dosageCell.addNewDosageTextField.text!)
                    } else {
                        delegate?.userDidSelectValue(dosageCell.addNewDosageTextField.text!)
                    }
                } else {
                    if !self.dosageDetailsArray.contains(dosageCell.addNewDosageTextField.text!) {
                        self.dosageDetailsArray.append(dosageCell.addNewDosageTextField.text!)
                        self.dosageDetailsArray =  self.dosageDetailsArray.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                        self.delegate?.newDosageAdded(dosageCell.addNewDosageTextField.text!)
                    } else {
                        delegate?.userDidSelectValue(dosageCell.addNewDosageTextField.text!)
                    }
                }
                self.dosageDetailTableView.reloadData()
            }
        }
    }
    
    func configureNavigationBarItems() {
        
            // Configure navigation title.
            switch (detailType.rawValue) {
                
            case eDoseValue.rawValue:
                viewTitleForDisplay = DOSE_VALUE_TITLE
            case eDoseFrom.rawValue:
                viewTitleForDisplay = DOSE_FROM_TITLE
            case eDoseTo.rawValue:
                viewTitleForDisplay = DOSE_TO_TITLE
            case eStartingDose.rawValue:
                viewTitleForDisplay = STARTING_DOSE_TITLE
            case eChangeOver.rawValue:
                viewTitleForDisplay = CHANGE_OVER_TITLE
            default:
                break
            }
            self.navigationItem.title = viewTitleForDisplay as String
            self.title = viewTitleForDisplay as String
        
    }
    
    // MARK: - TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (detailType == eChangeOver) {
            return 1
        } else if (detailType == eAddDoseForTime) {
            return 2
        } else if (dosageDetailsArray.count == 0){
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {

            if (detailType == eChangeOver) {
                return changeOverItemsArray.count
            } else if(detailType == eAddDoseForTime){
                return doseForTimeArray.count
            } else {
                if (dosageDetailsArray.count != 0) {
                    return dosageDetailsArray.count
                } else {
                    return 1
                }
            }
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            if (indexPath.section == 0) {
                let cellForDisplay : DCDosageDetailTableViewCell = self.configureCellForDisplay(indexPath)
                return cellForDisplay
            } else {
                let cellForDisplay : DCDosageDetailTableViewCell = self.configureCellForAddNew()
                return cellForDisplay
            }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0 ) {
            if (dosageDetailsArray.count != 0 || detailType == eChangeOver || detailType == eAddDoseForTime) {
                switch (detailType.rawValue) {
                    
                case eDoseValue.rawValue,eDoseFrom.rawValue,eDoseTo.rawValue,eStartingDose.rawValue:
                    delegate?.userDidSelectValue(dosageDetailsArray[indexPath.row])
                case eChangeOver.rawValue:
                    delegate?.userDidSelectValue(changeOverItemsArray[indexPath.row])
                case eAddDoseForTime.rawValue:
                    delegate?.userDidSelectValue(doseForTimeArray[indexPath.row])
                default:
                    break
                }
                self.navigationController?.popViewControllerAnimated(true)
            }else {
                // New dose textfield cell
//                    self.transitToAddNewScreen()
            }
        } else {
            // New dose textfield cell
//            self.transitToAddNewScreen()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44 //Choose your custom row height
    }
    
    // MARK: - Private Methods
    
    func configureCellForAddNew() -> DCDosageDetailTableViewCell{
        
        let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(ADD_NEW_VALUE_CELL_ID) as? DCDosageDetailTableViewCell
        dosageDetailCell?.addNewDosageTextField.delegate = dosageDetailCell
        dosageDetailCell?.accessoryType = .None
        return dosageDetailCell!
    }
    
    func configureCellForDisplay(indexPath: NSIndexPath) -> DCDosageDetailTableViewCell {
        
        let dosageDetailCell : DCDosageDetailTableViewCell? = dosageDetailTableView.dequeueReusableCellWithIdentifier(DOSE_DETAIL_CELL_ID) as? DCDosageDetailTableViewCell
        // Configure the cell...
        if (detailType == eChangeOver) {
            dosageDetailCell?.accessoryType = (previousSelectedValue == changeOverItemsArray[indexPath.row]) ? .Checkmark : .None
            dosageDetailCell!.dosageDetailDisplayCell.text = changeOverItemsArray[indexPath.row]
            return dosageDetailCell!
        } else if (detailType == eAddDoseForTime) {
            dosageDetailCell?.accessoryType = (previousSelectedValue == doseForTimeArray[indexPath.row]) ? .Checkmark : .None
            dosageDetailCell!.dosageDetailDisplayCell.text = doseForTimeArray[indexPath.row]
            return dosageDetailCell!
        }
        if (dosageDetailsArray.count != 0) {
            switch (detailType.rawValue) {
                
            case eDoseValue.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eDoseFrom.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eDoseTo.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            case eStartingDose.rawValue:
                dosageDetailCell?.accessoryType = (previousSelectedValue == dosageDetailsArray[indexPath.row]) ? .Checkmark : .None
                dosageDetailCell!.dosageDetailDisplayCell.text = dosageDetailsArray[indexPath.row]
            default:
                break
            }
            dosageDetailCell?.dosageDetailDisplayCell.textColor = UIColor.blackColor()
            return dosageDetailCell!
        } else {
            let cellForDisplay : DCDosageDetailTableViewCell = self.configureCellForAddNew()
            return cellForDisplay
        }
    }
    
    func transitToAddNewScreen (){
        
        let addNewDosageViewController : DCAddNewDoseAndTimeViewController? = UIStoryboard(name: DOSAGE_STORYBORD, bundle: nil).instantiateViewControllerWithIdentifier(ADD_NEW_DOSE_TIME_SBID) as? DCAddNewDoseAndTimeViewController
        addNewDosageViewController?.detailType = eAddNewDose
        addNewDosageViewController!.newDosageEntered = { value in
            self.previousSelectedValue = value!
            if self.detailType == eAddDoseForTime {
                if !self.doseForTimeArray.contains(value!) {
                    self.doseForTimeArray.append(value!)
                    self.doseForTimeArray =  self.doseForTimeArray.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                    self.delegate?.newDosageAdded(value!)
                }
            } else {
                if !self.dosageDetailsArray.contains(value!) {
                    self.dosageDetailsArray.append(value!)
                    self.dosageDetailsArray =  self.dosageDetailsArray.sort { NSString(string: $0).floatValue > NSString(string: $1).floatValue }
                    self.delegate?.newDosageAdded(value!)
                }
            }
            self.dosageDetailTableView.reloadData()
        }
        let navigationController: UINavigationController = UINavigationController(rootViewController: addNewDosageViewController!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func validateNewDosageValue (value: String) -> Bool {
        
        let scanner: NSScanner = NSScanner(string:value)
        let isNumeric = scanner.scanDecimal(nil) && scanner.atEnd
        return isNumeric && NSString(string: value).floatValue < maximumValueOfDose
    }
    
    // MARK: - Keyboard Delegate Methods

    func keyboardDidShow(notification : NSNotification) {
        
        //If the no of array elements is greater than the threshold value then the view should adjust.
        if appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow {
            if self.detailType == eAddDoseForTime {
                if doseForTimeArray.count > thresholdCountForKeyboardAppear {
                    self.dosageDetailTableView.contentOffset = CGPoint(x: 0, y: tableviewContentOffset * (doseForTimeArray.count - thresholdCountForKeyboardAppear))
                }
            } else {
                if dosageDetailsArray.count > thresholdCountForKeyboardAppear {
                    self.dosageDetailTableView.contentOffset = CGPoint(x: 0, y: tableviewContentOffset * (dosageDetailsArray.count - thresholdCountForKeyboardAppear))
                }
            }
        }
    }
    
    func keyboardDidHide(notification :NSNotification){
        
        //If the no of array elements is greater than the threshold value then the view should adjust to make the new entry visible.
        if appDelegate.windowState == DCWindowState.oneThirdWindow || appDelegate.windowState == DCWindowState.halfWindow {
            if self.detailType == eAddDoseForTime {
                if doseForTimeArray.count < thresholdCountForKeyboardDisappear {
                    self.dosageDetailTableView.contentOffset = CGPoint(x: zeroInt, y: -tableviewContentOffset);
                } else {
                    self.dosageDetailTableView.contentOffset = CGPoint(x: zeroInt, y: tableviewContentOffset * (doseForTimeArray.count - thresholdCountForKeyboardDisappear))
                }
            } else {
                if dosageDetailsArray.count < thresholdCountForKeyboardDisappear {
                    self.dosageDetailTableView.contentOffset = CGPoint(x: zeroInt, y: -tableviewContentOffset);
                } else {
                    self.dosageDetailTableView.contentOffset = CGPoint(x: zeroInt, y: tableviewContentOffset * (dosageDetailsArray.count - thresholdCountForKeyboardDisappear))
                }
            }
        }
    }
}
