//
//  DCAdministerGraphViewCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 17/02/16.
//
//

import UIKit
import Charts

class DCAdministerGraphViewCell: UITableViewCell,ChartViewDelegate {

    @IBOutlet weak var chartView: LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.chartView.delegate = self;
        
        self.chartView.descriptionText = ""
        self.chartView.noDataTextDescription = ""
        
        self.chartView.dragEnabled = true
        self.chartView.setScaleEnabled(true)
        self.chartView.pinchZoomEnabled = true
        self.chartView.drawGridBackgroundEnabled = false
        
        let leftAxis: ChartYAxis = chartView.leftAxis
        leftAxis.customAxisMax = 50
        leftAxis.customAxisMin = 0
        
        self.chartView.leftAxis.enabled = false
        self.chartView.rightAxis.enabled = false
        
        self.chartView.viewPortHandler.setMaximumScaleY(4)
        self.chartView.viewPortHandler.setMaximumScaleX(4)
        
        self.chartView.legend.form = ChartLegend.ChartLegendForm.Line
        self.chartView.legend.enabled = false
        
        self.configureGraphViewForDisplay()
//        self.chartView.animate(xAxisDuration: 1.5, easingOption: ChartEasingOption.EaseInOutQuart)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureGraphViewForDisplay() {

        var xVals = [String]()
        var startDate: NSDate = NSDate()
        let calendarStart: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendarStart.components([.Era, .Year, .Month, .Day, .Hour, .Minute], fromDate: startDate)
        comps.minute = 00
        //NSDateComponents handles rolling over between days, months, years, etc
        startDate = calendarStart.dateFromComponents(comps)!
        print(startDate)
        
        let daysToAdd: Double = 1
        let endDate: NSDate = startDate.dateByAddingTimeInterval(60 * 60 * 24 * daysToAdd)
        print(endDate)
        let minutesToAdd: Int = 1
        //Add an hour to date.
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components: NSDateComponents = NSDateComponents()
        components.minute = minutesToAdd

        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM \n HH:mm"
        let xAxiS: ChartXAxis = self.chartView.xAxis
        xAxiS.labelHeight = 45
        xAxiS.setLabelsToSkip(3)
        var i: Int = 0
        while i <= 420 {
            let stringFromDate: String = dateFormatter.stringFromDate(startDate)
            startDate = calendar.dateByAddingComponents(components, toDate: startDate, options: NSCalendarOptions.MatchFirst)!
            xVals.append(stringFromDate)
            NSLog("%@", stringFromDate)
            i++
        }
        self.chartView.extraTopOffset = 30
        self.chartView.extraLeftOffset = 20
        self.chartView.extraRightOffset = 20
        self.chartView.xAxis.axisLabelModulus = 60
//        self.chartView.xAxis.setLabelsToSkip(60)
//        self.chartView.xAxis = xAxiS

        var yVals1 = [ChartDataEntry]()
        var yVals2 = [ChartDataEntry]()
        var yVals3 = [ChartDataEntry]()
        
        yVals1.append(ChartDataEntry(value: 25, xIndex: 75))
        yVals1.append(ChartDataEntry(value: 25, xIndex: 150))
        yVals2.append(ChartDataEntry(value: 25, xIndex: 150))
        yVals2.append(ChartDataEntry(value: 25, xIndex: 250))
        yVals3.append(ChartDataEntry(value: 25, xIndex: 250))
        yVals3.append(ChartDataEntry(value: 25, xIndex: 400))

        var indexArray = [Int]()
        indexArray.append(Int(75))
        indexArray.append(Int(150))
        indexArray.append(Int(250))
        indexArray.append(Int(400))
        NSLog("%@",indexArray)

        let marker: DCGraphPoints = DCGraphPoints(color: self.chartView.tintColor, font: UIFont.systemFontOfSize(15.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0), markerIndexTextArray: indexArray)
        marker.minimumSize = CGSizeMake(80.0, 40.0)
        self.chartView.marker = marker

        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "Start")
        set1.colors = [chartView.tintColor]
        set1.lineWidth = 4.0
        set1.circleRadius = 5.0
        set1.drawCircleHoleEnabled = false
        set1.valueFont = UIFont.systemFontOfSize(9.0)
        set1.circleColors = [chartView.tintColor]
        set1.drawValuesEnabled = false

        let set2: LineChartDataSet = LineChartDataSet(yVals: yVals2, label: "")
        set2.lineDashLengths = [5.0, 5.0]
        set2.colors = [chartView.tintColor]
        set2.circleColors = [chartView.tintColor]
        set2.lineWidth = 4.0
        set2.circleRadius = 5.0
        set2.drawCircleHoleEnabled = false
        set2.valueFont = UIFont.systemFontOfSize(9.0)
        set2.drawValuesEnabled = false

        let set3: LineChartDataSet = LineChartDataSet(yVals: yVals3, label: "")
        set3.colors = [chartView.tintColor]
        set3.lineWidth = 4.0
        set3.circleRadius = 5.0
        set3.drawCircleHoleEnabled = false
        set3.valueFont = UIFont.systemFontOfSize(9.0)
        set3.drawValuesEnabled = false
        set3.circleColors = [chartView.tintColor]
        
        var dataSets = [ChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        let data: LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        self.chartView.data = data

    }
}
