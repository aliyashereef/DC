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
    var obsBodyTemperature = BodyTemperature()
    var obsRespiratory = Respiratory()
    var obsPulse = Pulse()
    var obsSPO2 = SPO2()
    var obsBM = BowelMovement()
    var obsBP = BloodPressure()
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
    
    func commonInit()
    {
        tableView.delegate=self
        tableView.dataSource=self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
//        
        let nib = UINib(nibName: "DoubleCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "DoubleCell")
        
        let nibTimePicker = UINib(nibName: "TimePickerCell", bundle: nil)
        self.tableView.registerNib(nibTimePicker, forCellReuseIdentifier: "TimePickerCell")
        
        let nibBloodPressure = UINib(nibName: "BloodPressureCell", bundle: nil)
        self.tableView.registerNib(nibBloodPressure, forCellReuseIdentifier: "BloodPressureCell")
        
        self.tableView.registerClass(DatePickerCellInline.self, forCellReuseIdentifier: "DatePickerCell")
        
        //
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
            cell.configureCell(cellTitle, valuePlaceHolderText: placeHolderText)
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
        for cell in tableView.visibleCells {
            switch(cell.tag)
            {
            case ObservationType.Date.rawValue:
                let dateCell = cell as! DatePickerCellInline
                obsBodyTemperature.date = dateCell.date
                obsRespiratory.date = dateCell.date
                obsPulse.date = dateCell.date
                obsSPO2.date = dateCell.date
                obsBM.date = dateCell.date
                obsBP.date = dateCell.date
            case ObservationType.Temperature.rawValue:
                let doubleCell = cell as! DoubleCell
                obsBodyTemperature.value = doubleCell.getValue()
            case ObservationType.Respiratory.rawValue:
                let doubleCell = cell as! DoubleCell
                obsRespiratory.repiratoryRate = doubleCell.getValue()
            case ObservationType.Pulse.rawValue:
                let doubleCell = cell as! DoubleCell
                obsPulse.pulseRate = doubleCell.getValue()
            case ObservationType.SpO2.rawValue:
                let doubleCell = cell as! DoubleCell
                obsSPO2.spO2Percentage = doubleCell.getValue()
            case ObservationType.BM.rawValue:
                let doubleCell = cell as! DoubleCell
                obsBM.value = doubleCell.getValue()
            case ObservationType.BloodPressure.rawValue:
                let bloodPressureCell = cell as! BloodPressureCell
                obsBP.systolic = bloodPressureCell.getSystolicValue()
                obsBP.diastolic = bloodPressureCell.getDiastolicValue()
            default:
                print("nothing have been selected", terminator: "")
            }
    }
    }
    

}