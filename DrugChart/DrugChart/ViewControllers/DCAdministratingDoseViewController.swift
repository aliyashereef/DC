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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let doseCell : DCAdministratingDoseTableViewCell = updateDoseTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eZerothSection.rawValue)) as? DCAdministratingDoseTableViewCell {
            if doseCell.doseTextField.text != doseValue {
                var reasonString: String = EMPTY_STRING
                if let reasonCell : DCInterventionAddResolveTextViewCell = updateDoseTableView.cellForRowAtIndexPath(NSIndexPath(forRow: RowCount.eZerothRow.rawValue, inSection: SectionCount.eFirstSection.rawValue)) as? DCInterventionAddResolveTextViewCell {
                    if reasonCell.reasonOrResolveTextView.text != EMPTY_STRING {
                        reasonString = reasonCell.reasonOrResolveTextView.text
                    }
                }
                self.doseValueUpdated(doseCell.doseTextField.text!,reasonString)
            }
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier(DOSE_DISPLAY_TEXTFIELD) as? DCAdministratingDoseTableViewCell
            cell?.doseTextField.text = doseValue
            cell!.doseString = doseValue
            cell?.doseTextField.delegate = cell
            cell?.textViewUpdated = { value in
                let section : NSIndexSet = NSIndexSet(index:SectionCount.eFirstSection.rawValue)
                if value {
                    if self.sectionCountOfTable != RowCount.eSecondRow.rawValue {
                        self.sectionCountOfTable = RowCount.eSecondRow.rawValue
                        tableView.insertSections(section, withRowAnimation: .Fade)
                    }
                } else {
                    if self.sectionCountOfTable == RowCount.eSecondRow.rawValue {
                        self.sectionCountOfTable = RowCount.eFirstRow.rawValue
                        tableView.deleteSections(section, withRowAnimation: .Fade)
                    }
                }
            }
            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(REASON_TEXT_VIEW) as? DCInterventionAddResolveTextViewCell
            cell!.placeHolderString = REASON
            cell?.initializeTextView()
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
