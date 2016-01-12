//
//  DCRouteAndInfusionsViewController.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 1/12/16.
//
//

import UIKit

@objc public protocol RoutesAndInfusionsDelegate {
    
    func newRouteSelected(route : NSString)
}

class DCRouteAndInfusionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var routesTableView: UITableView!
    var delegate : RoutesAndInfusionsDelegate?
    var routesArray : [String]? = []
    var previousRoute : String?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("ROUTES", comment: "screen title")
        routesArray = (DCPlistManager.medicationRoutesList() as? [String])!
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return routesArray!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let routeCell = tableView.dequeueReusableCellWithIdentifier(ROUTE_CELL_ID) as? DCRouteCell
        let route : NSString = routesArray![indexPath.item]
        routeCell?.titleLabel.text = route as String
        let range = route.rangeOfString(" ")
        let croppedString = route.substringToIndex(range.location)
        if (previousRoute?.containsString(croppedString) == true) {
            routeCell?.accessoryType = .Checkmark
        } else {
            routeCell?.accessoryType = .None
        }
        return routeCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let route : NSString = routesArray![indexPath.item]
        if let routeDelegate = delegate {
            routeDelegate.newRouteSelected(route)
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
