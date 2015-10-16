//
//  DCWardsListingPopoverViewController.swift
//  DrugChart
//
//  Created by aliya on 07/10/15.
//
//

import Foundation

protocol WardSelectionDelegate {
    func newWardSelected( row : NSInteger)
}

class DCWardsListingPopoverViewController : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var delegate : WardSelectionDelegate?
    var wardsArray : NSMutableArray = []
    @IBOutlet var wardsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wardsTableView.delegate = self
        self.title = "Wards"
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target:self, action: "cancelButtonPressed")
        self.navigationItem.rightBarButtonItem = cancelButton
        self.preferredContentSize = CGSizeMake(305, CGFloat(Double(wardsArray.count-1)*45.0))
        wardsTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        displayNavigationBarBasedOnSizeClass()
        super.viewDidLayoutSubviews()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : DCWardsCell = (tableView.dequeueReusableCellWithIdentifier("WardsCell") as? DCWardsCell)!
        cell.layoutMargins = UIEdgeInsetsZero
        let ward : DCWard  = wardsArray.objectAtIndex(indexPath.row) as! DCWard
        if let name = ward.wardName {
            cell.wardNameLabel.text = name

        }
        cell.wardNumberLabel.text = "Ward \(ward.wardNumber)"
        return cell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wardsArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate {
            delegate.newWardSelected(indexPath.row)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func displayNavigationBarBasedOnSizeClass(){
        let orientation : UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let windowWidth = DCUtility.getMainWindowSize().width
        if ((orientation == UIInterfaceOrientation.LandscapeLeft) || (orientation == UIInterfaceOrientation.LandscapeRight)) {
            if windowWidth > screenWidth/2 {
                showNavigationBar(false)
            } else {
                showNavigationBar(true)
            }
        } else {
            if windowWidth < screenWidth {
                showNavigationBar(true)
            } else {
                showNavigationBar(false)
            }
        }
    }
    
    func showNavigationBar(show:Bool) {
        if show == true {
            self.navigationController?.navigationBar.hidden = false
        } else {
            self.navigationController?.navigationBar.hidden = true
        }
    }
    
    func cancelButtonPressed() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}