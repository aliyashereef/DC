//
//  ChartingCell.swift
//  vitalsigns
//
//  Created by Noureen on 08/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit
import Charts


class LineChartCell: UITableViewCell {

    @IBOutlet weak var lineChart: LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//    func drawChart()
//    {
//        
//        // let months = ["31-Jan-2004","20-Feb-2005","20-Mar-2006","21-Apr-2008" ,"30-May-2013","21-Jun-2015"]
//        // let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
//        //setChart(months,values:unitsSold)
//        var yAxisValue = [Double]()
//        var xAxisValue = [String]()
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        for temperature in temperatureList
//        {
//            yAxisValue.append(temperature.value)
//            xAxisValue.append(formatter.stringFromDate(temperature.date))
//        }
//        setChart(xAxisValue, values: yAxisValue)
//    }
    
    func drawChart(dataPoints:[String] , values :[Double])
    {
        var dataEntries:[ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value:values[i] , xIndex : i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries )
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        
        lineChart.xAxis.labelPosition = .Bottom
        lineChart.rightAxis.enabled=false
        lineChart.legend.enabled=false
        lineChart.descriptionText=""
        lineChart.data = lineChartData
        
    }
}
