//
//  DCWardsListingPopoverViewController.swift
//  DrugChart
//
//  Created by aliya on 07/10/15.
//
//

import Foundation

let wardViewTitle : NSString = "Wards"
let wardsTableViewCellID : NSString = "WardsCell"

protocol WardSelectionDelegate {
    func newWardSelected( row : NSInteger)
}

class DCWardsListingPopoverViewController : DCBaseViewController , UITableViewDelegate , UITableViewDataSource {
    
    var delegate : WardSelectionDelegate?
    var wardsArray : NSMutableArray = []
    @IBOutlet var wardsTableView: UITableView!
    var searchActive : Bool = false
    var filteredArray = [AnyObject]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.wardsTableView.delegate = self
        self.title = wardViewTitle as String
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title:CANCEL_BUTTON_TITLE, style: UIBarButtonItemStyle.Plain, target:self, action: "cancelButtonPressed")
        self.navigationItem.rightBarButtonItem = cancelButton
//        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        self.preferredContentSize = CGSizeMake(DCUtility.popOverPreferredContentSize().width, CGFloat(Double(wardsArray.count-1)*45.0))
        self.navigationController!.preferredContentSize = CGSizeMake(DCUtility.popOverPreferredContentSize().width, CGFloat(Double(wardsArray.count-1)*45.0))
        wardsTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        displayNavigationBarBasedOnSizeClass()
        if !searchActive {
            wardsTableView.contentOffset = CGPoint(x: 0, y: 44)
        } else {
            wardsTableView.contentOffset = CGPointZero
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        searchActive = false;
//    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchActive = true
        let predicateString = NSString(format: "wardName contains[cd] '%@'",searchText)
        let predicate = NSPredicate(format: predicateString as String)
        filteredArray  = wardsArray.filteredArrayUsingPredicate(predicate)
//        if(filteredArray.count == 0){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
        self.wardsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : DCWardsCell = (tableView.dequeueReusableCellWithIdentifier(wardsTableViewCellID as String) as? DCWardsCell)!
//        cell.layoutMargins = UIEdgeInsetsZero
        let ward :DCWard?
        if(searchActive){
            ward = filteredArray[indexPath.row] as? DCWard
        } else {
            ward = wardsArray.objectAtIndex(indexPath.row) as? DCWard
        }
            if let name = ward!.wardName {
            cell.wardNameLabel.text = name
        }
        cell.wardNumberLabel.text = "Ward \(ward!.wardNumber)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return filteredArray.count
        }
        return wardsArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var indexOfSelectedWard : Int?
        if searchActive {
            indexOfSelectedWard = wardsArray.indexOfObject(filteredArray[indexPath.row])
        } else {
            indexOfSelectedWard = indexPath.row
        }
        if let delegate = self.delegate {
            delegate.newWardSelected(indexOfSelectedWard!)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayNavigationBarBasedOnSizeClass(){
        
        let orientation : UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let windowWidth = DCUtility.mainWindowSize().width
        if ((orientation == UIInterfaceOrientation.LandscapeLeft) || (orientation == UIInterfaceOrientation.LandscapeRight)) {
            if windowWidth > screenWidth/2 {
                showNavigationBar(false)
            } else {
                showNavigationBar(true)
            }
        } else {
            if windowWidth <= screenWidth {
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