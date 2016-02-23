////////////////////////////////////
//
//  GeneralObservationView.swift
//  vitalsigns
//
//  Created by Noureen on 16/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit


class GeneralObservationView: UIView ,UITableViewDelegate,UITableViewDataSource,CellDelegate{
    
    @IBOutlet var tableView: UITableView!
    private var obsBodyTemperature:BodyTemperature?
    private var obsRespiratory : Respiratory?
    private var obsPulse :Pulse?
    private var obsSPO2 : SPO2?
    private var obsBM : BowelMovement?
    private var obsBP :BloodPressure?
    var observation:VitalSignObservation!
    var showObservationType:ShowObservationType = ShowObservationType.All
    var uitag:DataEntryObservationSource!
    var delegate: ObservationDelegate?
    
    // section
    let SECTION_DATE = 0
    let SECTION_OBSERVATION = 1
    let SECTION_ADDITIONAL_NEWS_OBSERVATION = 2
    
    
    // rows
    let SECTION_DATE_ROWS = 1 // show one row for the date section
    let SECTION_OBSERVATION_ADD_ROWS = 5 // show all the observations becuase this is add case
    let SECTION_OBSERVATION_EDIT_ROWS = 1 // show only single observation because this is editing of a single observation
    let SECTION_ADDITIONAL_NEWS_OBSERVATION_ROWS = 2
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
            return 3
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
                    /*   case ShowObservationType.BM:
                    return 6*/
                case ShowObservationType.AdditionalOxygen:
                    return 6
                case ShowObservationType.AVPU:
                    return 7
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
       // var cellTitle:String = ""
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
                cell.value.text = observation.getRespiratoryReading()
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
                cell.value.text = observation.getSpo2Reading()
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
                cell.value.text = observation.getTemperatureReading()
            }
            cell.delegate = self
            return cell
            
        case ObservationType.BloodPressure:
            let cell = tableView.dequeueReusableCellWithIdentifier(bloodPressureCellIdentifier, forIndexPath: indexPath) as! BloodPressureCell
            cell.tag = ObservationType.BloodPressure.rawValue
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.BloodPressure && observation != nil && observation.bloodPressure != nil )
            {
                cell.systolicValue.text =  String( observation.bloodPressure!.systolic)
                cell.diastolicValue.text    = String(observation.bloodPressure!.diastolic)
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
                cell.value.text = observation.getPulseReading()
            }
            cell.delegate = self
            return cell
            
            /* case ObservationType.BM:
            cellTitle = "BM"
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DoubleCell", forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.BM.rawValue
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            cell.delegate = self
            return cell*/
        case ObservationType.AdditionalOxygen:
            let cell = tableView.dequeueReusableCellWithIdentifier(toggleCellIdentifier, forIndexPath: indexPath) as! ToggleCell
            cell.configureCell("Any Supplemental Oxygen")
            return cell
        case ObservationType.AVPU:
            let cell = tableView.dequeueReusableCellWithIdentifier(segmentedCellIdentifier, forIndexPath: indexPath) as! SwitchCell
            cell.configureCell("Level of Consciousness", values: ["A" , "V,P or U"])

            let infoButton = UIButton(type: .InfoLight)
            infoButton.addTarget(self, action: "showhelp", forControlEvents: .TouchUpInside )
            infoButton.tintColor = UIColor.darkGrayColor()
            cell.accessoryView = infoButton
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
            return observation.respiratory?.repiratoryRate
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
                if(showObservationType != ShowObservationType.All && showObservationType != ShowObservationType.None)
                {
                    switch(showObservationType)
                    {
                    case .Respiratory:
                        if(observation != nil && observation.respiratory != nil)
                        {
                            let cell = getCell(ObservationType.Respiratory.rawValue) as! DoubleCell
                            observation.respiratory?.repiratoryRate = cell.getValue()
                        }
                    case .SpO2:
                        if(observation != nil && observation.spo2 != nil)
                        {
                            let cell = getCell(ObservationType.SpO2.rawValue) as! DoubleCell
                            observation.spo2?.spO2Percentage = cell.getValue()
                        }
                    case .Temperature:
                        if(observation != nil && observation.temperature != nil)
                        {
                            let cell = getCell(ObservationType.Temperature.rawValue) as! DoubleCell
                            observation.temperature?.value = cell.getValue()
                        }
                    case .BloodPressure:
                        if(observation != nil && observation.bloodPressure != nil)
                        {
                            let cell = getCell(ObservationType.BloodPressure.rawValue) as! BloodPressureCell
                            observation.bloodPressure?.systolic = cell.getSystolicValue()
                            observation.bloodPressure?.diastolic = cell.getDiastolicValue()
                        }
                    case .Pulse:
                        if(observation != nil && observation.pulse != nil)
                        {
                            let cell = getCell(ObservationType.Pulse.rawValue) as! DoubleCell
                            observation.pulse?.pulseRate = cell.getValue()
                        }
                    default:
                        print("nothing happened")
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
            case ObservationType.Temperature.rawValue:
                let doubleCell = cell as! DoubleCell
                if doubleCell.isValueEntered()
                {
                    obsBodyTemperature = BodyTemperature()
                    obsBodyTemperature?.value = doubleCell.getValue()
                }
                else
                {
                    obsBodyTemperature = nil
                }
            case ObservationType.Respiratory.rawValue:
                let doubleCell = cell as! DoubleCell
                if(doubleCell.isValueEntered())
                {
                    obsRespiratory = Respiratory()
                    obsRespiratory!.repiratoryRate = doubleCell.getValue()
                }
                else
                {
                    obsRespiratory = nil
                }
            case ObservationType.Pulse.rawValue:
                let doubleCell = cell as! DoubleCell
                if(doubleCell.isValueEntered())
                {
                    obsPulse = Pulse()
                    obsPulse!.pulseRate = doubleCell.getValue()
                }
                else
                {
                    obsPulse = nil
                }
            case ObservationType.SpO2.rawValue:
                let doubleCell = cell as! DoubleCell
                if (doubleCell.isValueEntered())
                {
                    obsSPO2 = SPO2()
                    obsSPO2!.spO2Percentage = doubleCell.getValue()
                }
                else
                {
                    obsSPO2 = nil
                }
                /* case ObservationType.BM.rawValue:
                let doubleCell = cell as! DoubleCell
                if(doubleCell.isValueEntered())
                {
                obsBM = BowelMovement()
                obsBM!.value = doubleCell.getValue()
                }
                else
                {
                obsBM = nil
                }*/
            case ObservationType.BloodPressure.rawValue:
                let bloodPressureCell = cell as! BloodPressureCell
                if(bloodPressureCell.isValueEntered())
                {
                    obsBP = BloodPressure()
                    obsBP!.systolic = bloodPressureCell.getSystolicValue()
                    obsBP!.diastolic = bloodPressureCell.getDiastolicValue()
                }
                else
                {
                    obsBP = nil
                }
            default:
                print("nothing have been selected", terminator: "")
            }
            observation.bm = obsBM
            observation.bloodPressure = obsBP
            observation.spo2 = obsSPO2
            observation.respiratory = obsRespiratory
            observation.temperature = obsBodyTemperature
            observation.pulse = obsPulse
        }
               }
    }
    // Mark : Cell delegate
    func moveNext(rowNumber:Int)
    {
        //if(ObservationType.count)
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
    
}

