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
    var observationList = [VitalSignObservation]()
    let lineChartIdentifier = "ObservationCell"
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GraphicalDashBoardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }

    func commonInit()
    {
        collectionView.dataSource=self
        collectionView.delegate=self
        let nibLineChart = UINib(nibName: "LineGraphCell", bundle: nil)
        collectionView.registerNib(nibLineChart, forCellWithReuseIdentifier:lineChartIdentifier )
        
        let nibLineChart1 = UINib(nibName: "LineGraphCell", bundle: nil)
        collectionView.registerNib(nibLineChart1, forCellWithReuseIdentifier:"Blood Pressure" )
        
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
        var xAxisValue = [NSDate]()
        var cellTitle:String = ""
        
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
//        case DashBoardRow.BloodPressure.rawValue:
//            chartType = ChartType.BarChart
//            cellTitle = "Blood Pressure"
//            
//            for observation in observationList
//            {
//                if observation.bloodPressure == nil{
//                    continue
//                }
//                    yAxisValue.append((observation.bloodPressure?.systolic)!)
//                    yAxisValue2.append((observation.bloodPressure?.diastolic)!)
//                    xAxisValue.append(observation.getFormattedDate())
//             
//            }
        default:
            chartType = ChartType.None
        }
        
        
        switch(chartType)
        {
        case ChartType.LineChart:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier(lineChartIdentifier, forIndexPath: indexPath) as! LineGraphCell
            cell.drawGraph(xAxisValue, yAxisValue: yAxisValue , displayView: GraphDisplayView.Day ,graphTitle: cellTitle)
            return cell
//        case ChartType.BarChart:
//            let cell=collectionView.dequeueReusableCellWithReuseIdentifier("ObservationBarChartCell", forIndexPath: indexPath) as! BPCollectionViewCell
//           
//            cell.configureCell(cellTitle)
//            
//            if yAxisValue.count>0
//            {
//                cell.drawChart(xAxisValue,value1: yAxisValue,value2: yAxisValue2)
//            }
//            return cell
        default:
            let cell=collectionView.dequeueReusableCellWithReuseIdentifier(lineChartIdentifier, forIndexPath: indexPath) as! LineGraphCell
            cell.drawGraph(xAxisValue, yAxisValue: yAxisValue, displayView: .Day ,graphTitle: cellTitle)
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //return CGSizeMake(395,320)
        return GraphManager.graphSize()
    }
    
    func reloadView(observationList :[VitalSignObservation])
    {
        self.observationList = observationList
        collectionView.reloadData()
    }
    

}
