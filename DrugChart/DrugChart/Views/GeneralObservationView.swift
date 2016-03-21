////////////////////////////////////
//
//  GeneralObservationView.swift
//  vitalsigns
//
//  Created by Noureen on 16/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit
import CocoaLumberjack

class GeneralObservationView: UIView ,UITableViewDelegate,UITableViewDataSource,CellDelegate{
    
    @IBOutlet var tableView: UITableView!
    var observation:VitalSignObservation!
    var showObservationType:ShowObservationType = ShowObservationType.All
    var uitag:DataEntryObservationSource!
    var delegate: ObservationDelegate?
    // section
    let SECTION_DATE = 0
    let SECTION_OBSERVATION = 1
    let SECTION_ADDITIONAL_NEWS_OBSERVATION = 2
    let SECTION_NEWS_SCORE = 3
    
    
    // rows
    let SECTION_DATE_ROWS = 1 // show one row for the date section
    let SECTION_OBSERVATION_ADD_ROWS = 5 // show all the observations becuase this is add case
    let SECTION_OBSERVATION_EDIT_ROWS = 1 // show only single observation because this is editing of a single observation
    let SECTION_ADDITIONAL_NEWS_OBSERVATION_ROWS = 2
    let SECTION_NEWS_SCORE_ROWS = 1
    let ZERO_ROWS = 0
    
    //general variables
    let toggleCellIdentifier  = "ToggleCell"
    let doubleCellIdentifier = "DoubleCell"
    let bloodPressureCellIdentifier = "BloodPressureCell"
    let segmentedCellIdentifier = "SwitchCell"
    
    var datePickerCell:DatePickerCellInline!
    var cells:Dictionary<Int,UITableViewCell> = Dictionary<Int,UITableViewCell>()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GeneralObservationView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    override func awakeFromNib() {
        tableView.delegate=self
        tableView.dataSource=self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.allowsMultipleSelection = false
        
        let nib = UINib(nibName: "DoubleCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: doubleCellIdentifier)
//        
        let nibBloodPressure = UINib(nibName: "BloodPressureCell", bundle: nil)
        self.tableView.registerNib(nibBloodPressure, forCellReuseIdentifier: bloodPressureCellIdentifier)
        
        datePickerCell = DatePickerCellInline(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        let nibToggle = UINib(nibName: "ToggleCell", bundle: nil)
        self.tableView.registerNib(nibToggle, forCellReuseIdentifier: toggleCellIdentifier)
        
        let nibSwitch = UINib(nibName: "SwitchCell", bundle: nil)
        self.tableView.registerNib(nibSwitch, forCellReuseIdentifier: segmentedCellIdentifier)
        
    }
    func configureView(observation:VitalSignObservation,showobservatioType:ShowObservationType, tag:DataEntryObservationSource)
    {
        self.uitag = tag
        self.observation = observation
        self.tableView.reloadData()
        self.showObservationType = showobservatioType
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        switch(self.uitag!)
        {
        case DataEntryObservationSource.VitalSignAddIPad , DataEntryObservationSource.VitalSignAddIPhone,
        DataEntryObservationSource.VitalSignEditIPhone , DataEntryObservationSource.VitalSignEditIPad:
            return 2
        case DataEntryObservationSource.NewsIPad , DataEntryObservationSource.NewsIPhone:
            return 4
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch(self.uitag!)
        {
        case DataEntryObservationSource.VitalSignAddIPad  , DataEntryObservationSource.VitalSignAddIPhone:
            
            switch (section)
            {
                case SECTION_DATE:
                    return SECTION_DATE_ROWS;
                default:
                    return SECTION_OBSERVATION_ADD_ROWS
            }
        
        case DataEntryObservationSource.VitalSignEditIPad , DataEntryObservationSource.VitalSignEditIPhone:
            switch (section)
            {
                case SECTION_DATE:
                    return SECTION_DATE_ROWS;
                default:
                    return  SECTION_OBSERVATION_EDIT_ROWS
            }
            
        case DataEntryObservationSource.NewsIPad , DataEntryObservationSource.NewsIPhone:
          switch(section)
          {
            case SECTION_DATE:
                return SECTION_DATE_ROWS // only one row for date
            case SECTION_OBSERVATION:
                return SECTION_OBSERVATION_ADD_ROWS // 5 rows for observation
            case  SECTION_ADDITIONAL_NEWS_OBSERVATION:
                return SECTION_ADDITIONAL_NEWS_OBSERVATION // 2 rows for the additional oxygen and for the AVPU
          case SECTION_NEWS_SCORE:
                return SECTION_NEWS_SCORE_ROWS
          default:
               return ZERO_ROWS
            }
        }
    }
    
    
    func getRowNumber(indexPath:NSIndexPath) -> Int
    {
        if(showObservationType != .All)
        {
            if(indexPath.section == 0)
            {
                return 0
            }
            else
            {
                switch(showObservationType)
                {
                case ShowObservationType.Respiratory:
                    return 1
                case ShowObservationType.SpO2:
                    return 2
                case ShowObservationType.Temperature:
                    return 3
                case ShowObservationType.BloodPressure:
                    return 4
                case ShowObservationType.Pulse:
                    return 5
                case ShowObservationType.AdditionalOxygen:
                    return 6
                case ShowObservationType.AVPU:
                    return 7
                case ShowObservationType.News:
                    return 8
                default:
                    return 0
                }
            }
        }
        else
        {
            var rowNumber = 0
            for var section = ( indexPath.section - 1 )   ; section >= 0 ; --section
            {
                rowNumber += self.tableView.numberOfRowsInSection(section)
            }
            rowNumber += indexPath.row
            return rowNumber
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var placeHolderText = "enter value"
        let rowNumber = getRowNumber(indexPath)
        let obsType = ObservationType(rawValue: rowNumber)
        switch (obsType!)
        {
        case ObservationType.Date:
            let cell = datePickerCell
            cell.tag = ObservationType.Date.rawValue
            if(showObservationType != .All)
            {
                cell.userInteractionEnabled = false
            }
            
            return cell
            
        case ObservationType.Respiratory:
            let cell = tableView.dequeueReusableCellWithIdentifier(doubleCellIdentifier, forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.Respiratory.rawValue
            cell.configureCell("Resps (per minute)", valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.Respiratory && observation != nil )
            {
                cell.numericValue.text = observation.getRespiratoryReading()
            }
            
            cell.delegate = self
            return cell
            
        case ObservationType.SpO2:
            placeHolderText = "enter %"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(doubleCellIdentifier, forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.SpO2.rawValue
            cell.configureCell( "Oxygen Saturation & Inspired O2", valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.SpO2 && observation != nil )
            {
                cell.numericValue.text = observation.getSpo2Reading()
            }
            cell.delegate = self
            return cell
            
        case ObservationType.Temperature:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(doubleCellIdentifier, forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.Temperature.rawValue
            cell.configureCell("Temperature (°C)", valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.Temperature && observation != nil )
            {
                cell.numericValue.text = observation.getTemperatureReading()
            }
            cell.delegate = self
            return cell
            
        case ObservationType.BloodPressure:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(bloodPressureCellIdentifier, forIndexPath: indexPath) as! BloodPressureCell
            cell.tag = ObservationType.BloodPressure.rawValue
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.BloodPressure && observation != nil && observation.bloodPressure.isValueEntered() )
            {
                cell.systolicValue.text =  observation.bloodPressure.stringValueSystolic
                cell.diastolicValue.text    = observation.bloodPressure.stringValueDiastolic
            }
            cell.configureCell(showObservationType != .All)
            cell.delegate = self
            return cell
            
        case ObservationType.Pulse:
            let cell = tableView.dequeueReusableCellWithIdentifier(doubleCellIdentifier, forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.Pulse.rawValue
            cell.configureCell("Pulse (beats/min)", valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.Pulse && observation != nil )
            {
                cell.numericValue.text = observation.getPulseReading()
            }
            cell.delegate = self
            return cell
        case ObservationType.AdditionalOxygen:
            let cell = tableView.dequeueReusableCellWithIdentifier(toggleCellIdentifier, forIndexPath: indexPath) as! ToggleCell
            cells[rowNumber] = cell
            cell.tag = ObservationType.AdditionalOxygen.rawValue
            cell.delegate = self
            cell.configureCell("Any Supplemental Oxygen")
            return cell
        case ObservationType.AVPU:
            let cell = tableView.dequeueReusableCellWithIdentifier(segmentedCellIdentifier, forIndexPath: indexPath) as! SwitchCell
            cell.tag = ObservationType.AVPU.rawValue
            cell.delegate = self
            cell.configureCell("Level of Consciousness", values: ["A" , "V,P or U"])

            let infoButton = UIButton(type: .InfoLight)
            infoButton.addTarget(self, action: "showhelp", forControlEvents: .TouchUpInside )
            infoButton.tintColor = UIColor.darkGrayColor()
            cell.accessoryView = infoButton
            cells[rowNumber] = cell
            return cell
        case ObservationType.News:
            placeHolderText = ""
            let cell = tableView.dequeueReusableCellWithIdentifier(doubleCellIdentifier, forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.News.rawValue
            cell.configureCell("NEWS", valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cell.numericValue.enabled = false
            cell.numericValue.text = ""
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.Pulse && observation != nil )
            {
                cell.numericValue.text = observation.getPulseReading()
            }
            cell.delegate = self
            return cell
            
        }
        
    }
    
    func showhelp()
    {
        let controller = HelpViewController()
        let navigation = UINavigationController(rootViewController: controller)
        delegate?.ShowModalNavigationController(navigation)
    }
    
    func getSelectedValue(indexPath:NSIndexPath) ->Double!
    {
        let rowNumber = getRowNumber(indexPath)
        
        switch(rowNumber)
        {
        case ObservationType.Respiratory.rawValue:
            return observation.respiratory.repiratoryRate
        default:
            return nil
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect automatically if the cell is a DatePickerCell.
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if (cell.isKindOfClass(DatePickerCellInline)) {
            let datePickerTableViewCell = cell as! DatePickerCellInline
            datePickerTableViewCell.selectedInTableView(tableView)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else
        {
            if datePickerCell.expanded
            {
                datePickerCell.selectedInTableView(tableView)
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.section != 0)
        {
            return nil
        }
        else
        {
            return indexPath
        }
    }
    func getCell(rowNum:Int) -> UITableViewCell!
    {
        for cell in tableView.visibleCells {
            if(cell.tag == rowNum)
            {
                return cell
            }
        }
        return nil
    }
    
    func prepareObjects()
    {
        if(self.uitag == DataEntryObservationSource.NewsIPad || self.uitag == DataEntryObservationSource.NewsIPhone)
        {
            observation.calculateNews = true
        }
        if(uitag == DataEntryObservationSource.VitalSignEditIPad || uitag == DataEntryObservationSource.VitalSignEditIPhone)
                {
                    switch(showObservationType)
                    {
                    case .Respiratory:
                        if(observation != nil )
                        {
                            let cell = getCell(ObservationType.Respiratory.rawValue) as! DoubleCell
                            observation.respiratory.stringValue = cell.getStringValue()
                        }
                    case .SpO2:
                        if(observation != nil )
                        {
                            let cell = getCell(ObservationType.SpO2.rawValue) as! DoubleCell
                            observation.spo2.stringValue = cell.getStringValue()
                        }
                    case .Temperature:
                        if(observation != nil )
                        {
                            let cell = getCell(ObservationType.Temperature.rawValue) as! DoubleCell
                            observation.temperature.stringValue = cell.getStringValue()
                        }
                    case .BloodPressure:
                        if(observation != nil )
                        {
                            let cell = getCell(ObservationType.BloodPressure.rawValue) as! BloodPressureCell
                            observation.bloodPressure.stringValueSystolic = cell.getSystolicStringValue()
                            observation.bloodPressure.stringValueDiastolic = cell.getDiastolicStringValue()
                        }
                    case .Pulse:
                        if(observation != nil )
                        {
                            let cell = getCell(ObservationType.Pulse.rawValue) as! DoubleCell
                            observation.pulse.stringValue = cell.getStringValue()
                        }
                    default:
                        print("Not a valid option for prepareObjects ")
                    }
                }
                else
                {
        for cell in tableView.visibleCells {
            switch(cell.tag)
            {
            case ObservationType.Date.rawValue:
                let dateCell = cell as! DatePickerCellInline
                observation.date = dateCell.date
                observation.temperature.date = dateCell.date
                observation.pulse.date = dateCell.date
                observation.spo2.date = dateCell.date
                observation.bloodPressure.date = dateCell.date
                observation.respiratory.date = dateCell.date
            case ObservationType.Temperature.rawValue:
                let doubleCell = cell as! DoubleCell
                observation.temperature.stringValue = doubleCell.getStringValue()
                
            case ObservationType.Respiratory.rawValue:
                let doubleCell = cell as! DoubleCell
                observation.respiratory.stringValue = doubleCell.getStringValue()
            
            case ObservationType.Pulse.rawValue:
                let doubleCell = cell as! DoubleCell
                   observation.pulse.stringValue = doubleCell.getStringValue()
               
            case ObservationType.SpO2.rawValue:
                let doubleCell = cell as! DoubleCell
                observation.spo2.stringValue = doubleCell.getStringValue()
                
            case ObservationType.BloodPressure.rawValue:
                let bloodPressureCell = cell as! BloodPressureCell
                    observation.bloodPressure.stringValueSystolic = bloodPressureCell.getSystolicStringValue()
                    observation.bloodPressure.stringValueDiastolic = bloodPressureCell.getDiastolicStringValue()
            case ObservationType.AdditionalOxygen.rawValue:
                let toggleCell = cell as! ToggleCell
                observation.additionalOxygen = toggleCell.isOn()
            case ObservationType.AVPU.rawValue:
                let switchCell = cell as! SwitchCell
                observation.additionalOxygen = switchCell.getValue() == 0 ? false:true
            default:
                print("nothing have been selected", terminator: "")
            }
        }
    }
}
    // Mark : Cell delegate
    func moveNext(rowNumber:Int)
    {
        let cellNumber = rowNumber + 1
        if(cellNumber < ObservationType.count)
        {
            if let doubleCell = cells[cellNumber] as? DoubleCell
            {
                doubleCell.getFocus()
            }
            else if let bloodPressureCell = cells[cellNumber] as? BloodPressureCell
            {
                bloodPressureCell.getFocus()
            }
            
        }
        
    }
    func movePrevious(rowNumber:Int)
    {
        let cellNumber = rowNumber - 1
        if(cellNumber > 0)
        {
            if let doubleCell = cells[cellNumber] as? DoubleCell
            {
                doubleCell.getFocus()
            }
            else if let bloodPressureCell = cells[cellNumber] as? BloodPressureCell
            {
                bloodPressureCell.getFocus()
            }
        }
    }
    
    func cellValueChanged(rowNumber: Int, object:AnyObject) {
        
        if(self.uitag != DataEntryObservationSource.NewsIPad && self.uitag != DataEntryObservationSource.NewsIPhone)
            // only do it for the news score
        {
            return
        }
        let cellNumber = rowNumber
        let observationType = ObservationType(rawValue: cellNumber)
        switch(observationType!)
        {
        case ObservationType.Respiratory:
            let doubleCell = cells[cellNumber] as? DoubleCell
            let numericTextField = object as? NumericTextField
            let value =  numericTextField?.getValue()
            observation.respiratory.stringValue = numericTextField!.text!
            
           // print("respiratory value \(value) and \(doubleCell?.selected)")
            
            if(numericTextField?.isValueEntered() == false)
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
            else if(value <= 8 || value >= 25)
            {
                doubleCell?.setCellBackgroundColor (Constant.RED_COLOR)
            }
            else if(value >= 9 && value <= 11)
            {
                doubleCell?.setCellBackgroundColor (Constant.GREEN_COLOR)
            }
            else if(value >= 21 && value <= 24 )
            {
                doubleCell?.setCellBackgroundColor (Constant.AMBER_COLOR)
            }
            else
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
        case ObservationType.SpO2:
            let doubleCell = cells[cellNumber] as? DoubleCell
            let numericTextField = object as? NumericTextField
            
            let value =  numericTextField?.getValue()
            observation.spo2.stringValue = numericTextField!.text!
            
            //  print("spo2 value \(value) and \(doubleCell?.selected)")
            
            if(numericTextField?.isValueEntered() == false)
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
            else if(value <= 91)
            {
                doubleCell?.setCellBackgroundColor (Constant.RED_COLOR)
            }
            else if(value >= 92 && value <= 93)
            {
                doubleCell?.setCellBackgroundColor (Constant.AMBER_COLOR)
            }
            else if (value >= 94 && value <= 95)
            {
                doubleCell?.setCellBackgroundColor (Constant.GREEN_COLOR)
            }
            else
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
        case ObservationType.Temperature:
            let doubleCell = cells[cellNumber] as? DoubleCell
            let numericTextField = object as? NumericTextField
            let value =  numericTextField?.getValue()
            observation.temperature.stringValue = numericTextField!.text!
            
          //  print("temperature value \(value) and \(doubleCell?.selected)")
            
            if(numericTextField?.isValueEntered() == false)
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
            else if(value <= 35)
            {
                doubleCell?.setCellBackgroundColor (Constant.RED_COLOR)
            }
            else if(value >= 39.1)
            {
                doubleCell?.setCellBackgroundColor (Constant.AMBER_COLOR)
            }
            else if ((value >= 35.1 && value <= 36 ) || (value >= 38.1 && value <= 39))
            {
                doubleCell?.setCellBackgroundColor (Constant.GREEN_COLOR)
            }
            else
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
        case ObservationType.BloodPressure:
            let bloodPressureCell = cells[cellNumber] as? BloodPressureCell
            let numericTextField = object as? NumericTextField
            let value =  numericTextField?.getValue()
            observation.bloodPressure.stringValueSystolic = numericTextField!.text!
            
            //   print("blood pressure  \(value) and \(bloodPressureCell?.selected)")
            
            if(numericTextField?.isValueEntered() == false)
            {
                bloodPressureCell?.contentView.backgroundColor = (Constant.NO_COLOR)
            }
            else if(value <= 90 || value >= 220)
            {
                bloodPressureCell?.contentView.backgroundColor = (Constant.RED_COLOR)
            }
            else if(value >= 91 && value <= 100)
            {
                bloodPressureCell?.contentView.backgroundColor = (Constant.AMBER_COLOR)
            }
            else if (value >= 101 && value <= 110)
            {
                bloodPressureCell?.contentView.backgroundColor = (Constant.GREEN_COLOR)
            }
            else
            {
                bloodPressureCell?.contentView.backgroundColor = (Constant.NO_COLOR)
            }
        case ObservationType.Pulse:
            let doubleCell = cells[cellNumber] as? DoubleCell
            let numericTextField = object as? NumericTextField
            let value =  numericTextField?.getValue()
            observation.pulse.stringValue = numericTextField!.text!
            
            //print("pulse value \(value) and \(doubleCell?.selected)")
            
            if(numericTextField?.isValueEntered() == false)
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
            else if(value <= 40 || value >= 131)
            {
                doubleCell?.setCellBackgroundColor (Constant.RED_COLOR)
            }
            else if(value >= 111 && value <= 130)
            {
                doubleCell?.setCellBackgroundColor (Constant.AMBER_COLOR)
            }
            else if ((value >= 41 && value <= 50) || (value >= 91 && value <= 110))
            {
                doubleCell?.setCellBackgroundColor (Constant.GREEN_COLOR)
            }
            else
            {
                doubleCell?.setCellBackgroundColor (Constant.NO_COLOR)
            }
        case ObservationType.AdditionalOxygen:
            let toggleCell = cells[cellNumber] as? ToggleCell
            let switchValue = object as? UISwitch
            observation.additionalOxygen = (switchValue?.on)!
            if(switchValue?.on == true)
            {
                toggleCell?.setCellBackgroundColor(Constant.AMBER_COLOR)
            }
            else
            {
                toggleCell?.setCellBackgroundColor(Constant.NO_COLOR)
            }
        case ObservationType.AVPU:
            let switchCell = cells[cellNumber] as? SwitchCell
            let switchValue = object as? UISegmentedControl
            observation.isConscious = (switchValue?.selectedSegmentIndex == 1 ? false:true)
            if(switchValue?.selectedSegmentIndex == 1)// user has selected V,P or U
            {
                switchCell?.setCellBackgroundColor(Constant.RED_COLOR)
            }
            else
            {
                switchCell?.setCellBackgroundColor(Constant.NO_COLOR)
            }
        default:
            DDLogDebug("No valid row to perform cellValueChanged")
        }
        updateNewsScore()
    }
    
    func updateNewsScore()
    {
        let score = observation.getNews()
        let rowNumber  = getRowNumber(NSIndexPath(forRow: 0, inSection: SECTION_NEWS_SCORE))
        let doubleCell = cells[rowNumber] as? DoubleCell
        doubleCell?.numericValue.text = score
        let value = doubleCell?.getValue()
        if(value >= 1 && value <= 4 )
        {
            doubleCell?.setCellBackgroundColor(Constant.GREEN_COLOR)
        }
        else if(value >= 5 && value <= 6)
        {
            doubleCell?.setCellBackgroundColor(Constant.AMBER_COLOR)
        }
        else if(value >= 7)
        {
            doubleCell?.setCellBackgroundColor(Constant.RED_COLOR)
        }
        else
        {
            doubleCell?.setCellBackgroundColor(Constant.NO_COLOR)
        }
        
    }
}

