//
//  CommaScoreView.swift
//  vitalsigns
//
//  Created by Noureen on 16/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class CommaScoreView: UIView,UITableViewDelegate,UITableViewDataSource {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    @IBOutlet weak var tableView: UITableView!
    var delegate:RowSelectedDelegate?
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CommaScoreView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    func commonInit()
    {
        tableView.delegate=self
        tableView.dataSource=self
        let nib = UINib(nibName: "DoubleCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "DoubleCell")
        
        let nibPickerCell = UINib(nibName: "PickerCell", bundle: nil)
        self.tableView.registerNib(nibPickerCell, forCellReuseIdentifier: "PickerCell")
        
        let nibSelectionCell = UINib(nibName: "SelectionCell", bundle: nil)
        self.tableView.registerNib(nibSelectionCell, forCellReuseIdentifier: "SelectionCell")
        
        
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return CommaScoreTableSection.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch (section)
        {
        case CommaScoreTableSection.CommaScale.rawValue:
            return 3;
        case CommaScoreTableSection.Pupils.rawValue:
            return 2;
        case CommaScoreTableSection.LimbMovement.rawValue:
            return 2;
        default:
            return 1;
        }
    }
    
    func getKeyValuePairs(values:[String]) ->[KeyValue]
    {
        var keyValuePairs:[KeyValue]=[]
        var index:Int
        
        for index = values.count; index > 0; --index {
            keyValuePairs.append(KeyValue(paramKey: index, paramValue: values[index-1]))
        }
        return keyValuePairs
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var title:String
        var selectableOptions:[KeyValue]=[]
        
        switch(indexPath.section,indexPath.row)
        {
        case (0,0):
            selectableOptions = getKeyValuePairs(["Spontaneously","To speech","To pain","None"])
            title="Eyes open"
        case (0,1):
            selectableOptions = getKeyValuePairs(["Oriented","Confused","Inappropriate words","Incomprehensible sounds","None"]);
            title="Best verbal response"
            
        case (0,2):
            selectableOptions = getKeyValuePairs(["Obeys commands","Localise to pain","Withdraw to pain","Flexion to pain","Extension to pain","None"])
            title="Best motor response"
            
        case (1,0):
            selectableOptions = getKeyValuePairs( ["Brisk reaction","No reaction","Some reaction"])
            title="Right"
            
        case (1,1):
            selectableOptions = getKeyValuePairs(["Brisk reaction","No reaction","Some reaction"])
            title="Left"
            
        case (2,0):
                selectableOptions = getKeyValuePairs(["Normal power","Mild weakness","Severe weakness","Spastic flexion","Extension","No response"])
                title="Arms"
        case (2,1):
                selectableOptions = getKeyValuePairs(["Normal power","Mild weakness","Severe weakness","Extension","No response"])
                title="Legs"
              default:
                //TODO: NEED TO THROW EXCEPTION, THIS CASE WILL NEVER OCCUR
                selectableOptions = getKeyValuePairs([""])
                title=""
        }
            let cell = tableView.dequeueReusableCellWithIdentifier("SelectionCell", forIndexPath: indexPath) as! SelectionCell
        cell.configureCell(title,selectedValue: KeyValue(paramKey:0,paramValue:""), dataSource:selectableOptions )
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectionCell
        delegate?.RowSelected(cell.dataSource)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section)
        {
        case  CommaScoreTableSection.CommaScale.rawValue:
            return "Comma Scale"
        case CommaScoreTableSection.Pupils.rawValue:
            return "Pupils"
        case CommaScoreTableSection.LimbMovement.rawValue:
            return "Limb Movement"
        default:
            print("This condition shouldn't occur at runtime.Code is added for the sake of compilation.", terminator: "")
            return ""
        }
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //   view.tintColor = UIColor(red: 0/255, green: 102/255, blue: 153/255, alpha: 1)
    }
    
}