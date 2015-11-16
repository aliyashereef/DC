//
//  BarChartCollectionViewCell.swift
//  vitalsigns
//
//  Created by Noureen on 05/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit
import Charts

class BarChartCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var barChart: BarChartView!
    var months: [String]!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func drawChart(dataPoints:[String] , value1 :[Double] , value2:[Double])
    {
        var systolicDataEntries:[ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value:value1[i] , xIndex : i)
            systolicDataEntries.append(dataEntry)
        }
        
        var diastolicDataEntries:[ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value:value2[i] , xIndex : i)
            diastolicDataEntries.append(dataEntry)
        }

        let systolicDataSet = BarChartDataSet(yVals: systolicDataEntries, label: "Systolic" )
        systolicDataSet .setColor(UIColor.blueColor())
        let diastolicDataSet = BarChartDataSet(yVals: diastolicDataEntries ,label: "Diastolic")
        diastolicDataSet.setColor(UIColor.greenColor())
        
        var bloodPressureDataSets = [BarChartDataSet]()
        bloodPressureDataSets.append(systolicDataSet)
        bloodPressureDataSets.append(diastolicDataSet)
        
        let barChartData = BarChartData(xVals: dataPoints, dataSets: bloodPressureDataSets)
        
        barChart.xAxis.labelPosition = .Bottom
        barChart.rightAxis.enabled=false
        //barChart.legend.enabled=false
        barChart.descriptionText=""
        barChart.data = barChartData
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChart.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        var yVal2 = [Double]()
        for i in 111...122
        {
            let value = Double(i)
            yVal2.append(value)
        }
        
        var dataEntries2:[BarChartDataEntry] = []
        for i in 0..<dataPoints.count
        {
            let dataEntry = BarChartDataEntry(value:yVal2[i], xIndex: i)
            dataEntries2.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Systolic")
        chartDataSet.setColor(UIColor.redColor())
        let chartDataSet2 = BarChartDataSet(yVals: dataEntries2, label: "Diastolic")
        chartDataSet2.setColor(UIColor.blueColor())
        var dataSets = [BarChartDataSet]()
        dataSets.append(chartDataSet)
        dataSets.append(chartDataSet2)
        let chartData = BarChartData(xVals: months, dataSets: dataSets)
        barChart.data = chartData
        barChart.descriptionText = ""
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        barChart.xAxis.labelPosition = .Bottom
    }
}
