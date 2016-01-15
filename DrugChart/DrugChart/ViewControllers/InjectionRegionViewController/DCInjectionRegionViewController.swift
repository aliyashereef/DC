//
//  DCInjectionRegionViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/14/16.
//
//

import UIKit

let TABLE_SECTION_COUNT : NSInteger = 1
let TABLE_ROW_COUNT : NSInteger = 3

typealias InjectionRegionSelected = String? -> Void

class DCInjectionRegionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var injectionRegionTableView: UITableView!
    var contentArray : [String]? = []
    var previousRegion : String?
    var injectionRegion : InjectionRegionSelected?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("INTO", comment: "")
        contentArray = [CENTRAL_LINE, PERIPHERAL_LINE_ONE, PERIPHERAL_LINE_TWO]
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK : TableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return TABLE_SECTION_COUNT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return TABLE_ROW_COUNT
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let injectionCell = tableView.dequeueReusableCellWithIdentifier(INJECTION_CELL_ID, forIndexPath: indexPath) as? DCInjectionTableCell
        let region = contentArray![indexPath.item]
        injectionCell!.titleLabel.text = region
        if (region == previousRegion) {
            injectionCell?.accessoryType = .Checkmark
        } else {
            injectionCell?.accessoryType = .None
        }
        return injectionCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.injectionRegion!(contentArray![indexPath.item])
        self.navigationController?.popViewControllerAnimated(true)
    }

}
