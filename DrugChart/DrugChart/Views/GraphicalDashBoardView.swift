//
//  GraphicalDashBoardView.swift
//  vitalsigns
//
//  Created by Noureen on 17/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit

class GraphicalDashBoardView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,ObservationDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var observationList = [VitalSignObservation]()
    let lineChartIdentifier = "ObservationCell"
    let barChartIdentifier = "BloodPressureCell"
    
    var graphDisplayView:GraphDisplayView!
    var graphStartDate:NSDate!
    var graphEndDate:NSDate!
    var delegate: ObservationDelegate?
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GraphicalDashBoardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }

    override func awakeFromNib() {
        collectionView.dataSource=self
        collectionView.delegate=self
        let nibLineChart = UINib(nibName: "LineGraphCell", bundle: nil)
        collectionView.registerNib(nibLineChart, forCellWithReuseIdentifier:lineChartIdentifier )
        
        let nibBarChart = UINib(nibName: "BarGraphCell", bundle: nil)
        collectionView.registerNib(nibBarChart, forCellWithReuseIdentifier: barChartIdentifier)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DashBoardRow.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var chartType :ChartType
        var yAxisValue = [Double]()
        var yAxisValue2 = [Double]()
        var xAxisValue = [NSDate]()
        var cellTitle:String = ""
        var latestObservationText:String! = nil
        var latestObservationDate:NSDate! = nil
        
        switch(indexPath.row)
        {
        case DashBoardRow.Respiratory.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "Respiratory"
            for observation in observationList
            {
                if observation.respiratory == nil
                {
                    continue
                }
                    yAxisValue.append((observation.respiratory?.repiratoryRate)!)
                    xAxisValue.append(observation.date)
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.Respiratory)
            if(latestObservation != nil)
            {
                latestObservationText = latestObservation!.respiratory!.repiratoryRate.cleanValue + " breaths/min"
                latestObservationDate = latestObservation?.date
            }
            
        case DashBoardRow.Temperature.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "Temperature"
            
            for observation in observationList
            {
                if observation.temperature == nil
                {
                    continue
                }
                    yAxisValue.append((observation.temperature?.value)!)
                    xAxisValue.append(observation.date)
                
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.Temperature)
            if(latestObservation != nil)
            {
                latestObservationText = String(latestObservation!.temperature!.value) + " °C"
                latestObservationDate = latestObservation?.date
            }
        case DashBoardRow.Pulse.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "Pulse"
            
            for observation in observationList
            {
                if observation.pulse == nil
                {
                    continue
                }
                    yAxisValue.append((observation.pulse?.pulseRate)!)
                    xAxisValue.append(observation.date)
                
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.Pulse)
            if(latestObservation != nil)
            {
                latestObservationText = latestObservation!.pulse!.pulseRate.cleanValue + " bpm"
                latestObservationDate = latestObservation?.date
            }
        case DashBoardRow.SpO2.rawValue:
            chartType = ChartType.LineChart
            cellTitle = "SPO2"
            
            for observation in observationList
            {
                if observation.spo2 == nil{
                    continue
                }
                    yAxisValue.append((observation.spo2?.spO2Percentage)!)
                    xAxisValue.append(observation.date)
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.SpO2)
            if(latestObservation != nil)
            {
                latestObservationText = String(latestObservation!.spo2!.spO2Percentage) + " %"
                latestObservationDate = latestObservation?.date
            }
        case DashBoardRow.BM.rawValue:
                chartType = ChartType.LineChart
                cellTitle = "BM"
                
                for observation in observationList
                {
                    if observation.bm == nil
                    {
                        continue
                    }
                        yAxisValue.append((observation.bm?.value)!)
                        xAxisValue.append(observation.date)
                 }
                let latestObservation = delegate?.GetLatestObservation(DashBoardRow.BM)
                if(latestObservation != nil)
                {
                    latestObservationText = String(latestObservation!.bm!.value)
                    latestObservationDate = latestObservation?.date
                }
        case DashBoardRow.BloodPressure.rawValue:
            chartType = ChartType.BarChart
            cellTitle = "Blood Pressure"
            
            for observation in observationList
            {
                if observation.bloodPressure == nil{
                    continue
                }
                    yAxisValue.append((observation.bloodPressure?.systolic)!)
                    yAxisValue2.append((observation.bloodPressure?.diastolic)!)
                    xAxisValue.append(observation.date)
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.BloodPressure)
            if(latestObservation != nil)
            {
                latestObservationText = String(format:"%@ / %@", latestObservation!.bloodPressure!.systolic.cleanValue, latestObservation!.bloodPressure!.diastolic.cleanValue)
                
                latestObservationDate = latestObservation?.date
            }
        default:
            chartType = ChartType.None
        }
        
        
        switch(chartType)
        {
        case ChartType.LineChart:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier(lineChartIdentifier, forIndexPath: indexPath) as! LineGraphCell
            cell.drawLineGraph(xAxisValue, yAxisValue: yAxisValue , displayView: graphDisplayView ,graphTitle: cellTitle,graphStartDate:graphStartDate , graphEndDate:graphEndDate ,latestReadingText:latestObservationText , latestReadingDate:latestObservationDate)
            cell.delegate = self
            return cell
        case ChartType.BarChart:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier(barChartIdentifier, forIndexPath: indexPath) as! BarGraphCell
            
            cell.drawBarGraph(xAxisValue, yAxisMinValue: yAxisValue2 ,yAxisMaxValue: yAxisValue, displayView: graphDisplayView ,graphTitle: cellTitle,graphStartDate:graphStartDate , graphEndDate:graphEndDate,latestReadingText:latestObservationText , latestReadingDate:latestObservationDate)
            
            return cell
        default:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier(lineChartIdentifier, forIndexPath: indexPath) as! LineGraphCell
            cell.drawLineGraph(xAxisValue, yAxisValue: yAxisValue, displayView:graphDisplayView,graphTitle: cellTitle,graphStartDate: graphStartDate , graphEndDate:graphEndDate, latestReadingText:"" , latestReadingDate:NSDate())
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //return CGSizeMake(395,320)
        return GraphManager.graphSize()
    }
    
    func displayData(observationList :[VitalSignObservation],graphDisplayView:GraphDisplayView,graphStartDate:NSDate , graphEndDate:NSDate)
    {
        self.observationList = observationList
        self.graphStartDate = graphStartDate
        self.graphEndDate = graphEndDate
        self.graphDisplayView = graphDisplayView
        collectionView.reloadData()
    }
    
    
    //Mark: Delegate Implementation
    func PushViewController(navigationController:UIViewController)
    {
        delegate?.PushViewController(navigationController)
    }

}
