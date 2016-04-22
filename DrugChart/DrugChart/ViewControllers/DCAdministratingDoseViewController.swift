//
//  AdministratingDoseViewController.swift
//  DrugChart
//
//  Created by Felix Joseph on 19/04/16.
//
//

import UIKit

typealias DoseValueUpdated = (String, String) -> Void

class DCAdministratingDoseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sectionCountOfTable: Int = 1
    var doseValue : String?
    @IBOutlet weak var updateDoseTableView: UITableView!
    var doseValueUpdated: DoseValueUpdated = { dose, reason in }
    var isInEditMode: Bool = false
    var isDoseValueUpdated: TextViewUpdated = { value in }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isInEditMode == true {
            sectionCountOfTable = SectionCount.eSecondSection.rawValue
        }
    }
    
     override func viewWillDisappear(animated: Bool) {
        
        if let doseCell : DCAdministratingDoseTableViewCell = updateDoseTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)) as? DCAdministratingDoseTableViewCell {
            var reasonString: String = EMPTY_STRING
            if let reasonCell : DCInterventionAddResolveTextViewCell = updateDoseTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                if reasonCell.reasonOrResolveTextView.text != EMPTY_STRING {
                    reasonString = reasonCell.reasonOrResolveTextView.text
                }
            }
            self.doseValueUpdated(doseCell.doseTextField.text!,reasonString)
        }
        super.viewWillDisappear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sectionCountOfTable
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RowCount.eFirstRow.rawValue
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == SectionCount.eFirstSection.rawValue {
            return CGFloat(TEXT_VIEW_CELL_HEIGHT)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == SectionCount.eZerothSection.rawValue {
            let doseCell : DCAdministratingDoseTableViewCell = self.administratingDoseTextFieldCell()
            return doseCell
        } else {
            let reasonCell : DCInterventionAddResolveTextViewCell = self.reasonTextViewCell()
            return reasonCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func administratingDoseTextFieldCell() -> DCAdministratingDoseTableViewCell {
        
        let cell = updateDoseTableView.dequeueReusableCellWithIdentifier(DOSE_DISPLAY_TEXTFIELD) as? DCAdministratingDoseTableViewCell
        cell?.doseTextField.text = doseValue
        cell!.doseString = doseValue
        cell?.doseTextField.delegate = cell
        cell?.textViewUpdated = { value in
            let section : NSIndexSet = NSIndexSet(index:SectionCount.eFirstSection.rawValue)
            self.isDoseValueUpdated(value)
            if value {
                if self.sectionCountOfTable != RowCount.eSecondRow.rawValue {
                    self.sectionCountOfTable = RowCount.eSecondRow.rawValue
                    self.updateDoseTableView.insertSections(section, withRowAnimation: .Fade)
                }
            } else {
                if self.sectionCountOfTable == RowCount.eSecondRow.rawValue {
                    self.sectionCountOfTable = RowCount.eFirstRow.rawValue
                    self.updateDoseTableView.deleteSections(section, withRowAnimation: .Fade)
                }
            }
        }
        return cell!
    }
    
    func reasonTextViewCell() -> DCInterventionAddResolveTextViewCell {
        
        let cell = updateDoseTableView.dequeueReusableCellWithIdentifier(REASON_TEXT_VIEW) as? DCInterventionAddResolveTextViewCell
        cell!.placeHolderString = REASON
        cell?.initializeTextView()
        return cell!
    }
}
