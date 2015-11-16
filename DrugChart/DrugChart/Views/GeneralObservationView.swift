//
//  GeneralObservationView.swift
//  vitalsigns
//
//  Created by Noureen on 16/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class GeneralObservationView: UIView ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet var tableView: UITableView!
    private var obsBodyTemperature:BodyTemperature?
    private var obsRespiratory : Respiratory?
    private var obsPulse :Pulse?
    private var obsSPO2 : SPO2?
    private var obsBM : BowelMovement?
    private var obsBP :BloodPressure?
    var observation:VitalSignObservation!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GeneralObservationView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    func commonInit(observation:VitalSignObservation)
    {
        self.observation = observation
        tableView.delegate=self
        tableView.dataSource=self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        let nib = UINib(nibName: "DoubleCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "DoubleCell")
        
        let nibTimePicker = UINib(nibName: "TimePickerCell", bundle: nil)
        self.tableView.registerNib(nibTimePicker, forCellReuseIdentifier: "TimePickerCell")
        
        let nibBloodPressure = UINib(nibName: "BloodPressureCell", bundle: nil)
        self.tableView.registerNib(nibBloodPressure, forCellReuseIdentifier: "BloodPressureCell")
        
        self.tableView.registerClass(DatePickerCellInline.self, forCellReuseIdentifier: "DatePickerCell")
        
        //
    }
    func configureView(observation:VitalSignObservation)
    {
        self.observation = observation
        self.tableView.reloadData()
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return ObservationType.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch (section)
        {
        case ObservationType.Date.rawValue:
            return 2;
        default:
            return 1
            
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellTitle:String = ""
        var placeHolderText = "enter value"
        var rowTag : Int = -1
        var cellType:CellType = CellType.Double
        var populateValue :Bool = observation != nil
        switch (indexPath.section)
        {
        case ObservationType.Date.rawValue:
            if(indexPath.row == 0)
            {
                cellType = CellType.Date
                rowTag = ObservationType.Date.rawValue
            }
            else
            {
                cellType = CellType.Time
            }
        case ObservationType.Respiratory.rawValue:
            cellTitle = "Resps(per minute)"
            rowTag = ObservationType.Respiratory.rawValue
        case ObservationType.SpO2.rawValue:
            cellTitle = "Oxygen Saturation & Inspired O2"
            placeHolderText = "enter %"
            rowTag = ObservationType.SpO2.rawValue
            
        case ObservationType.Temperature.rawValue:
            cellTitle = "Temperature (Celcius)"
            rowTag = ObservationType.Temperature.rawValue
            
        case ObservationType.BloodPressure.rawValue:
            cellTitle="Systolic / Diastolic"
            rowTag = ObservationType.BloodPressure.rawValue
            cellType = CellType.BloodPressure
        case ObservationType.Pulse.rawValue:
            cellTitle = "Pulse(beats/min)"
            rowTag = ObservationType.Pulse.rawValue
            
        case ObservationType.BM.rawValue:
            cellTitle = "BM"
            rowTag = ObservationType.BM.rawValue
        
        default:
            cellTitle = ""
            
        }
        
        switch(cellType)
        {
        case CellType.Date:
            let cell = tableView.dequeueReusableCellWithIdentifier("DatePickerCell", forIndexPath: indexPath) as! DatePickerCellInline
            cell.tag = rowTag
            return cell
        case CellType.Time:
            let cell = tableView.dequeueReusableCellWithIdentifier("TimePickerCell", forIndexPath: indexPath) as! TimePickerCell
            cell.tag = rowTag
            return cell
        case CellType.BloodPressure:
            let cell = tableView.dequeueReusableCellWithIdentifier("BloodPressureCell", forIndexPath: indexPath) as! BloodPressureCell
            cell.tag = rowTag
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("DoubleCell", forIndexPath: indexPath) as! DoubleCell
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText,selectedValue: nil)
            cell.tag = rowTag
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section)
        {
        case  ObservationType.Respiratory.rawValue:
            return "Respiratory"
        case ObservationType.SpO2.rawValue:
            return "SPO2"
        case ObservationType.Temperature.rawValue:
            return "Temperature"
        case ObservationType.BloodPressure.rawValue:
            return "Blood Pressure"
        case ObservationType.Pulse.rawValue:
            return "Pulse"
        case ObservationType.BM.rawValue:
            return "BM Score"
        default:
            return ""
        }
    }
   
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        // Get the correct height if the cell is a DatePickerCell.
//        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
//        if (cell.isKindOfClass(DatePickerCellInline)) {
//            return (cell as! DatePickerCellInline).datePickerHeight()
//        }
//        else
//        {
//            //return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
//            return 44
//        }
//    }
//    
    func prepareObjects()
    {
       // observation = VitalSignObservation()
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
            observation.respiratiory = obsRespiratory
            observation.temperature = obsBodyTemperature
            observation.pulse = obsPulse
    }
    }
    

}
