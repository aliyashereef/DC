//
//  BPCollectionViewCell.swift
//  vitalsigns
//
//  Created by Noureen on 09/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit
import Charts

class BPCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bpChart: ScatterChartView!
    
    @IBOutlet weak var cellTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(title:String)
    {
        cellTitle.text = title
    }
    
    func drawChart(dataPoints:[String] , value1 :[Double] , value2:[Double])
    {
        var systolicDataEntries:[ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value:value1[i] , xIndex : i)
            systolicDataEntries.append(dataEntry)
        }
        
        var diastolicDataEntries:[ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value:value2[i] , xIndex : i)
            diastolicDataEntries.append(dataEntry)
        }
        
        let systolicDataSet = ScatterChartDataSet(yVals: systolicDataEntries, label: "Systolic" )
        //systolicDataSet.scatterShape = ScatterShape.Square
        systolicDataSet .setColor(UIColor.blueColor())
        let diastolicDataSet = ScatterChartDataSet(yVals: diastolicDataEntries ,label: "Diastolic")
        //diastolicDataSet.scatterShape = ScatterShape.Circle
        diastolicDataSet.setColor(UIColor.greenColor())
        
        var bloodPressureDataSets = [ScatterChartDataSet]()
        bloodPressureDataSets.append(systolicDataSet)
        bloodPressureDataSets.append(diastolicDataSet)
        
        let barChartData = ScatterChartData(xVals: dataPoints, dataSets: bloodPressureDataSets)
        
        bpChart.xAxis.labelPosition = .Bottom
        bpChart.rightAxis.enabled=false
        //barChart.legend.enabled=false
        bpChart.descriptionText=""
        bpChart.data = barChartData
        
    }
    
//    func drawChart(dataPoints:[String] , value1 :[Double] , value2:[Double])
//    {
//        var systolicDataEntries:[ChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
//            let dataEntry = ChartDataEntry(value:value1[i] , xIndex : i)
//            systolicDataEntries.append(dataEntry)
//        }
//        
//        var diastolicDataEntries:[ChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
//            let dataEntry = ChartDataEntry(value:value2[i] , xIndex : i)
//            diastolicDataEntries.append(dataEntry)
//        }
//        
//        let systolicDataSet = LineChartDataSet(yVals: systolicDataEntries, label: "Systolic" )
//        systolicDataSet .setColor(UIColor.blueColor())
//        let diastolicDataSet = LineChartDataSet(yVals: diastolicDataEntries ,label: "Diastolic")
//        diastolicDataSet.setColor(UIColor.greenColor())
//        //
//        var bloodPressureDataSets = [LineChartDataSet]()
//        bloodPressureDataSets.append(systolicDataSet)
//        bloodPressureDataSets.append(diastolicDataSet)
//        
//        let barChartData = LineChartData(xVals: dataPoints, dataSets: bloodPressureDataSets)
//        
//        bpChart.xAxis.labelPosition = .Bottom
//        bpChart.rightAxis.enabled=false
//        //barChart.legend.enabled=false
//        bpChart.descriptionText=""
//        bpChart.data = barChartData
//        
//    }
//    

}
