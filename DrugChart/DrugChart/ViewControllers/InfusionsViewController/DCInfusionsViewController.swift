//
//  DCInfusionsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/19/16.
//
//

import UIKit

@objc public protocol InfusionsDelegate {
    
    func updatedInfusionObject(infusion : DCInfusion)
}


class DCInfusionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var infusionsTableView: UITableView!
    var infusion : DCInfusion?
    var infusionDelegate : InfusionsDelegate?

    override func viewDidLoad() {
        
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let sectionCount = DCInfusionsHelper.infusionsTableViewSectionCount(self.infusion!.administerAsOption)
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let bolusCell = self.slowBolusCellIndexPath(indexPath)
        return bolusCell
    }
    
    func slowBolusCellIndexPath(indexPath : NSIndexPath) -> DCSlowBolusCell {
        
        //configure slow bolus cell
        let bolusCell = infusionsTableView.dequeueReusableCellWithIdentifier(SLOW_BOLUS_CELL_ID) as? DCSlowBolusCell
        if let switchState = self.infusion?.bolusInjection?.slowBolus {
            bolusCell?.bolusSwitch.on = switchState
        }
        bolusCell?.switchState = { state in
            let switchValue : Bool = state!
            self.infusion?.bolusInjection?.slowBolus = switchValue
            if let delegate = self.infusionDelegate {
                delegate.updatedInfusionObject(self.infusion!)
            }
        }
        return bolusCell!
    }

    
}
