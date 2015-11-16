//
//  BarChartCell.swift
//  vitalsigns
//
//  Created by Noureen on 05/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit
import Charts


class BarChartCell: UITableViewCell {

    @IBOutlet weak var barChartView: BarChartView!
    var months: [String]!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK : draw the chart with provided values
    func drawChart(dataPoints:[String] , values :[Double])
    {

        //barChartView.delegate = self;
        
        barChartView.descriptionText = "";
        barChartView.noDataTextDescription = "Data will be loaded soon."
        
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = true
        
        barChartView.maxVisibleValueCount = 60
        barChartView.pinchZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = true
        barChartView.drawBordersEnabled = false
        
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        setChart(months, values: unitsSold)
        
//        var dataEntries:[ChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
//            let dataEntry = ChartDataEntry(value:values[i] , xIndex : i)
//            dataEntries.append(dataEntry)
//        }
//        
//        let lineChartDataSet = LineChartDataSet(yVals: dataEntries )
//        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
//        
//        lineChart.xAxis.labelPosition = .Bottom
//        lineChart.rightAxis.enabled=false
//        lineChart.legend.enabled=false
//        lineChart.descriptionText=""
//        lineChart.data = lineChartData
//        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.descriptionText = ""
        
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        //        chartDataSet.colors = ChartColorTemplates.colorful()
        
        barChartView.xAxis.labelPosition = .Bottom
        
        //        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        //        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
        let ll = ChartLimitLine(limit: 10.0, label: "Target")
        barChartView.rightAxis.addLimitLine(ll)
        
    }
}
    

