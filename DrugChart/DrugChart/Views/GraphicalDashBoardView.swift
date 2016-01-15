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
    let GRAPH_HORIZONTAL_LINES = 4
    
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
    
    func getGraphData(cellObservationType:DashBoardRow, cellTitle:String)-> GraphModel!
    {
        switch(cellObservationType)
        {
        case DashBoardRow.Respiratory:
            let graphData:LineGraphModel = LineGraphModel()
            graphData.cellTitle = cellTitle
            graphData.graphStartDate = graphStartDate
            graphData.graphEndDate = graphEndDate
            graphData.graphDisplayView = graphDisplayView
      
            for observation in observationList
            {
                if observation.respiratory == nil
                {
                    continue
                }
                graphData.yAxisValue.append((observation.respiratory?.repiratoryRate)!)
                graphData.xAxisValue.append(observation.date)
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.Respiratory)
            if(latestObservation != nil)
            {
                graphData.latestObservationText = latestObservation!.respiratory!.repiratoryRate.cleanValue + " breaths/min"
                graphData.latestObservationDate = latestObservation?.date
            }
            return graphData
        case DashBoardRow.Temperature:
            let graphData:LineGraphModel = LineGraphModel()
            graphData.cellTitle = cellTitle
            graphData.graphStartDate = graphStartDate
            graphData.graphEndDate = graphEndDate
            graphData.graphDisplayView = graphDisplayView
            
            
            for observation in observationList
            {
                if observation.temperature == nil
                {
                    continue
                }
                graphData.yAxisValue.append((observation.temperature?.value)!)
                graphData.xAxisValue.append(observation.date)
                
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.Temperature)
            if(latestObservation != nil)
            {
                graphData.latestObservationText = String(latestObservation!.temperature!.value) + " °C"
                graphData.latestObservationDate = latestObservation?.date
            }
            return graphData
        case DashBoardRow.Pulse:
            let graphData:LineGraphModel = LineGraphModel()
            graphData.cellTitle = cellTitle
            graphData.graphStartDate = graphStartDate
            graphData.graphEndDate = graphEndDate
            graphData.graphDisplayView = graphDisplayView
            
            
            for observation in observationList
            {
                if observation.pulse == nil
                {
                    continue
                }
                graphData.yAxisValue.append((observation.pulse?.pulseRate)!)
                graphData.xAxisValue.append(observation.date)
                
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.Pulse)
            if(latestObservation != nil)
            {
                graphData.latestObservationText = latestObservation!.pulse!.pulseRate.cleanValue + " bpm"
                graphData.latestObservationDate = latestObservation?.date
            }
            return graphData
        case DashBoardRow.SpO2:
            let graphData:LineGraphModel = LineGraphModel()
            graphData.cellTitle = cellTitle
            graphData.graphStartDate = graphStartDate
            graphData.graphEndDate = graphEndDate
            graphData.graphDisplayView = graphDisplayView
            
            
            for observation in observationList
            {
                if observation.spo2 == nil{
                    continue
                }
                graphData.yAxisValue.append((observation.spo2?.spO2Percentage)!)
                graphData.xAxisValue.append(observation.date)
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.SpO2)
            if(latestObservation != nil)
            {
                graphData.latestObservationText = String(latestObservation!.spo2!.spO2Percentage) + " %"
                graphData.latestObservationDate = latestObservation?.date
            }
            return graphData
      /*  case DashBoardRow.BM:
            let graphData:LineGraphModel = LineGraphModel()
            graphData.cellTitle = cellTitle
            graphData.graphStartDate = graphStartDate
            graphData.graphEndDate = graphEndDate
            graphData.graphDisplayView = graphDisplayView
            
            
            for observation in observationList
            {
                if observation.bm == nil
                {
                    continue
                }
                graphData.yAxisValue.append((observation.bm?.value)!)
                graphData.xAxisValue.append(observation.date)
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.BM)
            if(latestObservation != nil)
            {
                graphData.latestObservationText = String(latestObservation!.bm!.value)
                graphData.latestObservationDate = latestObservation?.date
            }
            return graphData*/
        case DashBoardRow.BloodPressure:
            let graphData:BarGraphModel = BarGraphModel()
            graphData.cellTitle = cellTitle
            graphData.graphStartDate = graphStartDate
            graphData.graphEndDate = graphEndDate
            graphData.graphDisplayView = graphDisplayView
            
            
            for observation in observationList
            {
                if observation.bloodPressure == nil{
                    continue
                }
                graphData.yAxisMaxValue.append((observation.bloodPressure?.systolic)!)
                graphData.yAxisMinValue.append((observation.bloodPressure?.diastolic)!)
                graphData.xAxisValue.append(observation.date)
            }
            let latestObservation = delegate?.GetLatestObservation(DashBoardRow.BloodPressure)
            if(latestObservation != nil)
            {
                graphData.latestObservationText = String(format:"%@ / %@", latestObservation!.bloodPressure!.systolic.cleanValue, latestObservation!.bloodPressure!.diastolic.cleanValue)
                
                graphData.latestObservationDate = latestObservation?.date
            }
            return graphData
       
        }
    }
    
    func getGraphTitle(cellObservationType:DashBoardRow) ->String
    {
        switch(cellObservationType)
        {
        case DashBoardRow.Respiratory:
            return "Respiratory"
        case DashBoardRow.Temperature:
            return "Temperature"
             case DashBoardRow.Pulse:
            return "Pulse"
        case DashBoardRow.SpO2:
            return "SPO2"
      /*  case DashBoardRow.BM:
            return "BM"*/
        case DashBoardRow.BloodPressure:
            return "Blood Pressure"
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var chartType :ChartType
        var cellTitle:String = ""
        var cellObservationType:DashBoardRow!
        
        var graphData:GraphModel!
        let dashBoardRowIdentifier = DashBoardRow(rawValue: indexPath.row)
        switch(dashBoardRowIdentifier!)
        {
        case DashBoardRow.Respiratory:
            chartType = ChartType.LineChart
            cellObservationType = DashBoardRow.Respiratory
            cellTitle = getGraphTitle(cellObservationType)
            graphData = getGraphData(cellObservationType,cellTitle: cellTitle)
            
        case DashBoardRow.Temperature:
            chartType = ChartType.LineChart
            cellObservationType = DashBoardRow.Temperature
            cellTitle = getGraphTitle(cellObservationType)
            graphData = getGraphData(cellObservationType,cellTitle: cellTitle)
            
        case DashBoardRow.Pulse:
            chartType = ChartType.LineChart
            cellObservationType = DashBoardRow.Pulse
            cellTitle = getGraphTitle(cellObservationType)
            graphData = getGraphData(cellObservationType,cellTitle: cellTitle)
            
        case DashBoardRow.SpO2:
            chartType = ChartType.LineChart
            cellObservationType = DashBoardRow.SpO2
            cellTitle = getGraphTitle(cellObservationType)
            graphData = getGraphData(cellObservationType,cellTitle: cellTitle)
            
     /*   case DashBoardRow.BM:
                chartType = ChartType.LineChart
                cellObservationType = DashBoardRow.BM
                cellTitle = getGraphTitle(cellObservationType)
                graphData = getGraphData(cellObservationType,cellTitle: cellTitle)
        */    
        case DashBoardRow.BloodPressure:
            chartType = ChartType.BarChart
            cellObservationType = DashBoardRow.BloodPressure
            cellTitle = getGraphTitle(cellObservationType)
            graphData = getGraphData(cellObservationType,cellTitle: cellTitle)
        }
        
        
        switch(chartType)
        {
        case ChartType.LineChart:
            let lineGraphData = graphData as! LineGraphModel
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(lineChartIdentifier, forIndexPath: indexPath) as! LineGraphCell
           
            cell.drawLineGraph(lineGraphData.xAxisValue, yAxisValue: lineGraphData.yAxisValue , displayView: graphDisplayView ,graphTitle: cellTitle,graphStartDate:lineGraphData.graphStartDate , graphEndDate:lineGraphData.graphEndDate ,latestReadingText:lineGraphData.latestObservationText , latestReadingDate:lineGraphData.latestObservationDate,noOfHorizontalLines: GRAPH_HORIZONTAL_LINES)
           
            cell.cellObservationType = cellObservationType
            cell.delegate = self
            return cell
        case ChartType.BarChart:
            let barGraphData = graphData as! BarGraphModel
            
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier(barChartIdentifier, forIndexPath: indexPath) as! BarGraphCell
            cell.delegate = self
            cell.cellObservationType = cellObservationType
            cell.drawBarGraph(barGraphData.xAxisValue, yAxisMinValue: barGraphData.yAxisMinValue ,yAxisMaxValue: barGraphData.yAxisMaxValue, displayView: graphDisplayView ,graphTitle: barGraphData.cellTitle,graphStartDate:barGraphData.graphStartDate , graphEndDate:barGraphData.graphEndDate,latestReadingText:barGraphData.latestObservationText , latestReadingDate:barGraphData.latestObservationDate,noOfHorizontalLines: GRAPH_HORIZONTAL_LINES)
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width =  collectionView.frame.width
        let CORNER_MARGIN:CGFloat = 20
        let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate
        if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
            width = width - CORNER_MARGIN
            return CGSizeMake(width,264)
        }
        else{
            
            let graphWidth:CGFloat = width/2
            width = graphWidth - CORNER_MARGIN
            return CGSizeMake(width,320)
    }
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
        let singleLineGraphController = navigationController as? SingleLineGraphController
        if (singleLineGraphController != nil)
        {
            let graphData = getGraphData(singleLineGraphController!.observationType, cellTitle: getGraphTitle(singleLineGraphController!.observationType)) as! LineGraphModel
             singleLineGraphController?.graphData = graphData
        }
        else
        {
            let singleBarGraphController = navigationController as! SingleBarGraphController
            let graphData = getGraphData(singleBarGraphController.observationType, cellTitle: getGraphTitle(singleBarGraphController.observationType)) as! BarGraphModel
                singleBarGraphController.graphData = graphData
        }
        
        delegate?.PushViewController(navigationController)
    }

}
