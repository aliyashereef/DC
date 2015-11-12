//
//  LineChartCollectionViewCell.swift
//  vitalsigns
//
//  o9≥klmg78ih;8 by Noureen on 09/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import UIKit
import Charts

class LineChartCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lineChart: LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
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
