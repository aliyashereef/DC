//
//  SelectionView.swift
//  vitalsigns
//
//  Created by Noureen on 09/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

class SelectionView: UITableViewController {
        
    private var dataSource:[KeyValue] = [KeyValue]()
    private var selectedValue:KeyValue?
    var delegate:RowSelectedDelegate?
    var tag:Int!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureView(data:[KeyValue],tag:Int,selectedValue:KeyValue? , title:String)
    {
        self.navigationItem.title = title
        dataSource = data
        self.tag = tag
        self.selectedValue = selectedValue
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CheckCell") as UITableViewCell!
       
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CheckCell")
        }
        
        let rowData = dataSource[indexPath.row]
        cell?.textLabel?.text = rowData.value
        if selectedValue?.key == rowData.key
        {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedData = dataSource[indexPath.row]
        delegate?.RowSelectedWithObject(selectedData, tag:tag)
    }
    
}
