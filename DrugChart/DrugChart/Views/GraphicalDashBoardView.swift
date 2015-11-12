//
//  GraphicalDashBoardView.swift
//  vitalsigns
//
//  Created by Noureen on 17/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class GraphicalDashBoardView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var temperatureList = [BodyTemperature]()
    var respiratoryList = [Respiratory]()
    var pulseList = [Pulse]()
    var spO2List = [SPO2]()
    var bmList = [BowelMovement]()
    var bpList = [BloodPressure]()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GraphicalDashBoardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }

    func commonInit()
    {
        collectionView.dataSource=self
        collectionView.delegate=self
        let nibLineChart = UINib(nibName: "LineChartCollectionViewCell", bundle: nil)
        collectionView.registerNib(nibLineChart, forCellWithReuseIdentifier: "ObservationCell")
        
        let nibBarChart = UINib(nibName: "BPCollectionViewCell", bundle: nil)
        collectionView.registerNib(nibBarChart, forCellWithReuseIdentifier: "ObservationBarChartCell")
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DashBoardRow.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var chartType :ChartType
        var yAxisValue = [Double]()
        var yAxisValue2 = [Double]()
        var xAxisValue = [String]()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        var cellTitle:String = ""
        
        switch(indexPath.row)
        {
        case DashBoardRow.Respiratory.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "Respiratory"
            for respiratory in respiratoryList
            {
                yAxisValue.append(respiratory.repiratoryRate)
                xAxisValue.append(formatter.stringFromDate(respiratory.date))
            }
            
        case DashBoardRow.Temperature.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "Temperature"
            
            for temperature in temperatureList
            {
                yAxisValue.append(temperature.value)
                xAxisValue.append(formatter.stringFromDate(temperature.date))
            }
        case DashBoardRow.Pulse.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "Pulse"
            
            for pulse in pulseList
            {
                yAxisValue.append(pulse.pulseRate)
                xAxisValue.append(formatter.stringFromDate(pulse.date))
            }
        case DashBoardRow.SpO2.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "SPO2"
            
            for spO2 in spO2List
            {
                yAxisValue.append(spO2.spO2Percentage)
                xAxisValue.append(formatter.stringFromDate(spO2.date))
            }
        case DashBoardRow.BM.rawValue:
                chartType = ChartType.LineChart
                cellTitle = "BM"
                
                for bm in bmList
                {
                    yAxisValue.append(bm.value)
                    xAxisValue.append(formatter.stringFromDate(bm.date))
                }
        case DashBoardRow.BloodPressure.rawValue:
            chartType = ChartType.BarChart
            cellTitle = "Blood Pressure"
            
            for bp in bpList
            {
                yAxisValue.append(bp.systolic)
                yAxisValue2.append(bp.diastolic)
                xAxisValue.append(formatter.stringFromDate(bp.date))
            }
        default:
            chartType = ChartType.None
        }
        
        
        switch(chartType)
        {
        case ChartType.LineChart:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier("ObservationCell", forIndexPath: indexPath) as! LineChartCollectionViewCell
            cell.configureCell(cellTitle)
            if yAxisValue.count>0
            {
            cell.drawChart(xAxisValue, values: yAxisValue)
            }
            return cell
        case ChartType.BarChart:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier("ObservationBarChartCell", forIndexPath: indexPath) as! BPCollectionViewCell
           
            cell.configureCell(cellTitle)
            
            if yAxisValue.count>0
            {
                cell.drawChart(xAxisValue,value1: yAxisValue,value2: yAxisValue2)
            }
            return cell
        default:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier("ObservationCell", forIndexPath: indexPath) 
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(308,264)
    }
    
    func reloadView(paramTemperatureList:[BodyTemperature],paramRespiratoryList:[Respiratory] , paramPulseList :[Pulse],paramSPO2List:[SPO2],paramBMList:[BowelMovement],paramBPList:[BloodPressure])
    {
        temperatureList = paramTemperatureList
        respiratoryList = paramRespiratoryList
        pulseList = paramPulseList
        spO2List = paramSPO2List
        bmList = paramBMList
        bpList = paramBPList
        collectionView.reloadData()
    }
    

}
