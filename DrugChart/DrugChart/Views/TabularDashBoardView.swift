//
//  TabularDashBoardView.swift
//  vitalsigns
//
//  Created by Noureen on 17/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class TabularDashBoardView: UIView ,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    // MARK: - Table view data source
    
    var delegate: ObservationEditDelegate? = nil
    
    func commonInit()
    {
        tableView.delegate=self
        tableView.dataSource=self
        //delegate = ObservationEditDelegate
        let nib = UINib(nibName: "ObservationsDetailsCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "ObservationDetailsCell")
    }
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TabularDashBoardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ObservationDetailsCell", forIndexPath: indexPath) as! ObservationsDetailsCell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 130;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let observationDetails : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("vcObservationMaintenance") as UIViewController
                let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
                navigationController?.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover = navigationController?.popoverPresentationController
                observationDetails.preferredContentSize = CGSizeMake(300,430)
                popover?.permittedArrowDirections = .Up
                popover?.preferredContentSize
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ObservationsDetailsCell?
                popover!.sourceView = cell
                self.delegate?.EditObservation(navigationController!)

    }
    //MARK : TODO: NEED TO RESOLVE THE ACCESSORY BUTTON TYPE NOT CALLING ISSUE
//    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        let observationDetails : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("testViewController") as UIViewController
//        let navigationController : UINavigationController? = UINavigationController(rootViewController: observationDetails)
//        navigationController?.modalPresentationStyle = UIModalPresentationStyle.Popover
//        let popover = navigationController?.popoverPresentationController
//        observationDetails.preferredContentSize = CGSizeMake(300,300)
//        popover?.permittedArrowDirections = .Up
//        popover?.preferredContentSize
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ObservationsDetailsCell?
//        popover!.sourceView = cell
//        self.delegate?.EditObservation(navigationController!)
//
//    }
    
}
