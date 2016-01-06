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
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var datePickerCell:DatePickerCellInline!
    var cells:Dictionary<Int,UITableViewCell> = Dictionary<Int,UITableViewCell>()
    //[(cellNumber:Int,cell:UICollectionViewCell)] = [(cellNumber:Int,cell:UICollectionViewCell)]()
    
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
        self.tableView.registerNib(nib, forCellReuseIdentifier: "DoubleCell")
        
        let nibTimePicker = UINib(nibName: "TimePickerCell", bundle: nil)
        self.tableView.registerNib(nibTimePicker, forCellReuseIdentifier: "TimePickerCell")
        
        let nibBloodPressure = UINib(nibName: "BloodPressureCell", bundle: nil)
        self.tableView.registerNib(nibBloodPressure, forCellReuseIdentifier: "BloodPressureCell")
        datePickerCell = DatePickerCellInline(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
    }
    func configureView(observation:VitalSignObservation,showobservatioType:ShowObservationType)
    {
        self.observation = observation
        self.tableView.reloadData()
        self.showObservationType = showobservatioType
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch (section)
        {
        case ObservationType.Date.rawValue:
            return 1;
        default:
            if(showObservationType == .All)
            {
                return 6
            }
            else
            {
                return  1
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
                case ShowObservationType.BM:
                    return 6
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
        var cellTitle:String = ""
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
            cellTitle = "Resps (per minute)"
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DoubleCell", forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.Respiratory.rawValue
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            if(showObservationType == ShowObservationType.Respiratory && observation.respiratory != nil )
            {
                cell.value.text = String( observation.respiratory!.repiratoryRate)
            }
            cell.delegate = self
            return cell
      
        case ObservationType.SpO2:
            cellTitle = "Oxygen Saturation & Inspired O2"
            placeHolderText = "enter %"
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DoubleCell", forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.SpO2.rawValue
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            cell.delegate = self
            return cell
            
        case ObservationType.Temperature:
            cellTitle = "Temperature (°C)"
            //rowTag =
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DoubleCell", forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.Temperature.rawValue
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            cell.delegate = self
            return cell
            
        case ObservationType.BloodPressure:
            cellTitle="Systolic / Diastolic"
            
            let cell = tableView.dequeueReusableCellWithIdentifier("BloodPressureCell", forIndexPath: indexPath) as! BloodPressureCell
            cell.tag = ObservationType.BloodPressure.rawValue
            cells[rowNumber] = cell
            cell.configureCell(showObservationType != .All)
            cell.delegate = self
            return cell
            
        case ObservationType.Pulse:
            cellTitle = "Pulse (beats/min)"
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DoubleCell", forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.Pulse.rawValue
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            cell.delegate = self
            return cell
            
        case ObservationType.BM:
            cellTitle = "BM"
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DoubleCell", forIndexPath: indexPath) as! DoubleCell
            cell.tag = ObservationType.BM.rawValue
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText,selectedValue: nil , disableNavigation: showObservationType != .All)
            cells[rowNumber] = cell
            cell.delegate = self
            return cell
            
        }

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
        }
     
    }
    
    func prepareObjects()
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
            case ObservationType.BM.rawValue:
                let doubleCell = cell as! DoubleCell
                if(doubleCell.isValueEntered())
                {
                    obsBM = BowelMovement()
                    obsBM!.value = doubleCell.getValue()
                }
                else
                {
                    obsBM = nil
                }
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
