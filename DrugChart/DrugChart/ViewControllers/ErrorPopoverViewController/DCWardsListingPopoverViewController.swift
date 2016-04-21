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
let wardsCellHeight = 45.0

protocol WardSelectionDelegate {
    func newWardSelected( row : NSInteger)
}

class DCWardsListingPopoverViewController : DCBaseViewController , UITableViewDelegate , UITableViewDataSource , UISearchBarDelegate{
    
    var delegate : WardSelectionDelegate?
    var wardsArray : NSMutableArray = []
    @IBOutlet var wardsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false
    var filteredArray = [AnyObject]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.wardsTableView.delegate = self
        self.title = wardViewTitle as String
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title:CANCEL_BUTTON_TITLE, style: UIBarButtonItemStyle.Plain, target:self, action: #selector(DCWardsListingPopoverViewController.cancelButtonPressed))
        self.navigationItem.rightBarButtonItem = cancelButton
//        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        self.preferredContentSize = CGSizeMake(DCUtility.popOverPreferredContentSize().width, CGFloat(Double(wardsArray.count)*wardsCellHeight))
        self.navigationController!.preferredContentSize = CGSizeMake(DCUtility.popOverPreferredContentSize().width, CGFloat(Double(wardsArray.count)*wardsCellHeight))
        wardsTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        displayNavigationBarBasedOnSizeClass()
    }
    
//MARK: UISearchBarDelegate methods
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        self.wardsTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        if searchText.characters.count == 0 {
            filteredArray = wardsArray as [AnyObject]
        } else {
            searchWardListWithText(searchText)
        }
        self.wardsTableView.reloadData()

    }
    
    //MARK: TableViewDelegate Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : DCWardsCell = (tableView.dequeueReusableCellWithIdentifier(wardsTableViewCellID as String) as? DCWardsCell)!
        let ward :DCWard?
        if(searchActive){
            ward = filteredArray[indexPath.row] as? DCWard
        } else {
            ward = wardsArray[indexPath.row] as? DCWard
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
    
    //MARK: Private Methods
    
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
    
    func searchWardListWithText (text : NSString){
        
        let predicateString = NSString(format: "wardName contains[cd] '%@'",text)
        let predicate = NSPredicate(format: predicateString as String)
        filteredArray  = wardsArray.filteredArrayUsingPredicate(predicate)
        self.wardsTableView.reloadData()
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