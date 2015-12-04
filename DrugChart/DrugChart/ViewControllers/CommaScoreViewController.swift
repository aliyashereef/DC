//
//  CommaScoreViewController.swift
//  DrugChart
//
//  Created by Noureen on 27/11/2015.
//
//

import UIKit

class CommaScoreViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RowSelectedDelegate {

    var eyesOpen:KeyValue!
    var bestVerbalResponse:KeyValue!
    var bestMotorResponse:KeyValue!
    var pupilRight:KeyValue!
    var pupilLeft:KeyValue!
    var limbMovementArms:KeyValue!
    var limbMovementLegs:KeyValue!
    var observation:VitalSignObservation!
    @IBOutlet weak var tableView: UITableView!
    var delegate:RowSelectedDelegate?
    var datePickerCell:DatePickerCellInline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate=self
        tableView.dataSource=self
        let nibSelectionCell = UINib(nibName: "SelectionCell", bundle: nil)
        self.tableView.registerNib(nibSelectionCell, forCellReuseIdentifier: "SelectionCell")
        datePickerCell = DatePickerCellInline(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        if(observation == nil)
        {
            observation = VitalSignObservation()
        }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    
    @IBAction func cancelClick(sender: AnyObject) {
        //self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func Refresh()
    {
        self.tableView.reloadData()
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
        var tag:Int = 0
        var selectedData:KeyValue?
        switch(indexPath.section,indexPath.row)
        {
        case (0,0):
            let cell = datePickerCell
            //cell.tag = rowTag
            return cell
        case (1,0):
            selectableOptions = getKeyValuePairs(["Spontaneously","To speech","To pain","None"])
            title="Eyes open"
            tag = CommaScoreTableRow.EyesOpen.rawValue
            selectedData = eyesOpen
        case (1,1):
            selectableOptions = getKeyValuePairs(["Oriented","Confused","Inappropriate words","Incomprehensible sounds","None"]);
            title="Best verbal response"
            tag = CommaScoreTableRow.BestVerbalResponse.rawValue
            selectedData = bestVerbalResponse
        case (1,2):
            selectableOptions = getKeyValuePairs(["Obeys commands","Localise to pain","Withdraw to pain","Flexion to pain","Extension to pain","None"])
            title="Best motor response"
            tag = CommaScoreTableRow.BestMotorResponse.rawValue
            selectedData = bestMotorResponse
        case (2,0):
            selectableOptions = getKeyValuePairs( ["Brisk reaction","No reaction","Some reaction"])
            title="Right"
            tag = CommaScoreTableRow.RightPupil.rawValue
            selectedData = pupilRight
        case (2,1):
            selectableOptions = getKeyValuePairs(["Brisk reaction","No reaction","Some reaction"])
            title="Left"
            tag = CommaScoreTableRow.LeftPupil.rawValue
            selectedData = pupilLeft
        case (3,0):
            selectableOptions = getKeyValuePairs(["Normal power","Mild weakness","Severe weakness","Spastic flexion","Extension","No response"])
            title="Arms"
            tag = CommaScoreTableRow.ArmsMovement.rawValue
            selectedData = limbMovementArms
        case (3,1):
            selectableOptions = getKeyValuePairs(["Normal power","Mild weakness","Severe weakness","Extension","No response"])
            title="Legs"
            tag = CommaScoreTableRow.LegsMovement.rawValue
            selectedData = limbMovementLegs
        default:
            //TODO: NEED TO THROW EXCEPTION, THIS CASE WILL NEVER OCCUR
            selectableOptions = getKeyValuePairs([""])
            title=""
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectionCell", forIndexPath: indexPath) as! SelectionCell
        cell.configureCell(title,selectedValue: selectedData, dataSource:selectableOptions )
        cell.tag = tag
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        header.textLabel?.textColor = UIColor.blackColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch(indexPath.section,indexPath.row)
        {
        case (0,0):
            let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
            let datePickerTableViewCell = cell as! DatePickerCellInline
            datePickerTableViewCell.selectedInTableView(tableView)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        default:
            if datePickerCell.expanded
            {
                datePickerCell.selectedInTableView(tableView)
            }
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectionCell
        let selectionController = SelectionView(nibName:"SelectionView",bundle:nil)
        selectionController.configureView(cell.dataSource,tag: cell.tag,selectedValue: cell.selectedValue,title: cell.title.text!)
        selectionController.delegate = self
        self.navigationController?.pushViewController(selectionController, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch(indexPath.section)
        {
        case ObservationType.Date.rawValue:
            return datePickerCell.datePickerHeight()
        default:
            return self.tableView.rowHeight
        }
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
    
    func RowSelectedWithObject(dataSource:KeyValue ,tag:Int)
    {
        switch(tag)
        {
        case CommaScoreTableRow.EyesOpen.rawValue:
            eyesOpen = dataSource
        case CommaScoreTableRow.BestVerbalResponse.rawValue:
            bestVerbalResponse = dataSource
        case CommaScoreTableRow.BestMotorResponse.rawValue:
            bestMotorResponse = dataSource
        case CommaScoreTableRow.RightPupil.rawValue:
            pupilRight = dataSource
        case CommaScoreTableRow.LeftPupil.rawValue:
            pupilLeft = dataSource
        case CommaScoreTableRow.ArmsMovement.rawValue:
            limbMovementArms = dataSource
        case CommaScoreTableRow.LegsMovement.rawValue:
            limbMovementLegs = dataSource
        default:
            NSLog("Do nothing")
        }
        Refresh()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func prepareObject()
    {
        observation.date = datePickerCell.date
        observation.eyesOpen = eyesOpen
        observation.bestVerbalResponse = bestVerbalResponse
        observation.bestMotorResponse = bestMotorResponse
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = sender as? UIBarButtonItem
        {
            prepareObject()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
