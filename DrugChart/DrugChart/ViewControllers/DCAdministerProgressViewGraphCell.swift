//
//  DCAdministerProgressViewGraphCell.swift
//  DrugChart
//
//  Created by Felix Joseph on 26/02/16.
//
//

import UIKit
import Charts

class DCAdministerProgressViewGraphCell: UITableViewCell,ChartViewDelegate {

    var startDate: NSDate = NSDate()
    var nextDate: NSDate = NSDate()
    var endDate : NSDate = NSDate()
    var dataDictionary = [String: String]()
    var dataArray = [[String:String]]()
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate

    @IBOutlet weak var chartView: CombinedChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.chartView.delegate = self
        
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
        self.chartView.xAxis.axisLineWidth = 0
        self.chartView.xAxis.gridColor = UIColor.grayColor()
        self.chartView.xAxis.drawGridLinesEnabled = false
        self.chartView.xAxis.drawLabelsEnabled = false
        
        self.chartView.viewPortHandler.setMaximumScaleY(1)
        self.chartView.viewPortHandler.setMaximumScaleX(1)
        
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
        
        // Array for adding x-axis values.
        var xVals = [String]()
        
        // Function to create dummy data for displaying in the graph.
        self.createTemporaryGraphData()
        let actualEndDate: NSDate = startDate.dateByAddingTimeInterval(60 * 295)
        
        // Create NSDateComponents to add 1 minute to current time.
        let minutesToAdd: Int = 1
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components: NSDateComponents = NSDateComponents()
        components.minute = minutesToAdd
        
        // Create the NSDateFormatter to format the date into required format.
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM \n HH:mm"
        
        // Format the x-Axis to the correct type.
        let xAxiS: ChartXAxis = self.chartView.xAxis
        xAxiS.labelFont = UIFont.systemFontOfSize(9)
        xAxiS.labelTextColor = UIColor.grayColor()
        xAxiS.setLabelsToSkip(60)
        
        // Enter the x-Axis values to the array.
        nextDate = startDate
        while nextDate <= endDate {
            let stringFromDate: String = dateFormatter.stringFromDate(nextDate)
            nextDate = calendar.dateByAddingComponents(components, toDate: nextDate, options: NSCalendarOptions.MatchFirst)!
            xVals.append(stringFromDate)
        }
        
        // Configure the chartview to required size.
        self.chartView.extraTopOffset = 15
        self.chartView.extraBottomOffset = 15

        if appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow {
            self.chartView.extraLeftOffset = 40
            self.chartView.extraRightOffset = 40
        } else {
            self.chartView.extraLeftOffset = 85
            self.chartView.extraRightOffset = 85
        }
        self.chartView.xAxis.axisLabelModulus = 60
        
        // Chart data object
        let combinedData: CombinedChartData = CombinedChartData(xVals: xVals)
        
        // Ordinary formatter.
        let ordinaryDateFormatter = NSDateFormatter()
        ordinaryDateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        ordinaryDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss xx"
        
        var yVals = [ChartDataEntry]()
        var dataSet = [ChartDataSet]()
        var timeIndex : Int = 0
        var nameBubbleYVals = [BubbleChartDataEntry]()
        var valueBubbleYVals = [BubbleChartDataEntry]()
        var bubbleDataSet = [ChartDataSet]()
        var valueString : String?
        
        for var index = 0 ; index < dataArray.count; index++ {
            yVals = []
            
            print(dataArray)
            nameBubbleYVals = []
            valueBubbleYVals = []
            let eventData = dataArray[index]
            switch eventData["event"]! {
            case "Started","ReStarted":
                // Find the difference between the start time in graph and the event start time in minutes.
                // This value is the index of starting point of event.
                nextDate = ordinaryDateFormatter.dateFromString(eventData["startTime"]!)!
                timeIndex = calendar.components(.Minute, fromDate: startDate, toDate: nextDate, options: []).minute
                yVals.append(ChartDataEntry(value: 25, xIndex: timeIndex))
                
                // Create a bubble in the start point and set the value as "S".
                nameBubbleYVals.append(BubbleChartDataEntry(xIndex: timeIndex, value: 25, size: 0))
                
                let nameBubbleChart: BubbleChartDataSet = BubbleChartDataSet(yVals: nameBubbleYVals, label: "")
                nameBubbleChart.setColor(chartView.tintColor, alpha: 1)
                nameBubbleChart.drawValuesEnabled = true
                nameBubbleChart.valueFont = UIFont.systemFontOfSize(9)
                nameBubbleChart.valueColors = [UIColor.whiteColor()]
                
                let numberFormatterS: NSNumberFormatter = NSNumberFormatter()
                if eventData["event"] == "Started" {
                    numberFormatterS.zeroSymbol = "S"
                } else {
                    numberFormatterS.zeroSymbol = "R"
                }
                nameBubbleChart.valueFormatter = numberFormatterS
                
                // Create a bubble below the starting point to display the start time.
                valueBubbleYVals.append(BubbleChartDataEntry(xIndex: timeIndex, value: 10, size: 0))
                
                let valueBubbleChart: BubbleChartDataSet = BubbleChartDataSet(yVals: valueBubbleYVals, label: "")
                valueBubbleChart.setColor(UIColor.clearColor(), alpha: 0)
                valueBubbleChart.drawValuesEnabled = true
                valueBubbleChart.valueFont = UIFont.systemFontOfSize(7)
                valueBubbleChart.valueColors = [UIColor.grayColor()]
                
                let numberFormatterValue1: NSNumberFormatter = NSNumberFormatter()
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH.mm"
                timeFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                valueString = timeFormatter.stringFromDate(nextDate)
                numberFormatterValue1.zeroSymbol = valueString
                valueBubbleChart.valueFormatter = numberFormatterValue1
                
                bubbleDataSet.append(nameBubbleChart)
                bubbleDataSet.append(valueBubbleChart)
                
                // Find the difference between the start time in graph and the event start time in minutes.
                // This value is the index of ending point of event.
                nextDate = ordinaryDateFormatter.dateFromString(eventData["endTime"]!)!
                timeIndex = calendar.components(.Minute, fromDate: startDate, toDate: nextDate, options: []).minute
                yVals.append(ChartDataEntry(value: 25, xIndex: timeIndex))
                
                let set: LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
                set.colors = [chartView.tintColor]
                set.lineWidth = 1.0
                if index == dataArray.count - 1 {
                    set.drawCirclesEnabled = false
                    set.circleRadius = 1.0
                } else {
                    set.circleRadius = 7.0
                }
                set.drawCircleHoleEnabled = false
                set.valueFont = UIFont.systemFontOfSize(9.0)
                set.circleColors = [chartView.tintColor]
                set.drawValuesEnabled = false
                
                
                dataSet.append(set)
            case "Paused" :
                // Find the difference between the start time in graph and the event start time in minutes.
                // This value is the index of starting point of event.
                nextDate = ordinaryDateFormatter.dateFromString(eventData["startTime"]!)!
                timeIndex = calendar.components(.Minute, fromDate: startDate, toDate: nextDate, options: []).minute
                yVals.append(ChartDataEntry(value: 25, xIndex: timeIndex))
                
                // Create a bubble in the start point and set the value as "S".
                nameBubbleYVals.append(BubbleChartDataEntry(xIndex: timeIndex, value: 25, size: 0))
                
                let nameBubbleChart: BubbleChartDataSet = BubbleChartDataSet(yVals: nameBubbleYVals, label: "")
                nameBubbleChart.setColor(chartView.tintColor, alpha: 1)
                nameBubbleChart.drawValuesEnabled = true
                nameBubbleChart.valueFont = UIFont.systemFontOfSize(9)
                nameBubbleChart.valueColors = [UIColor.whiteColor()]
                
                let numberFormatterS: NSNumberFormatter = NSNumberFormatter()
                numberFormatterS.zeroSymbol = "P"
                nameBubbleChart.valueFormatter = numberFormatterS
                
                // Create a bubble below the starting point to display the start time.
                valueBubbleYVals.append(BubbleChartDataEntry(xIndex: timeIndex, value: 10, size: 0))
                
                let valueBubbleChart: BubbleChartDataSet = BubbleChartDataSet(yVals: valueBubbleYVals, label: "")
                valueBubbleChart.setColor(UIColor.clearColor(), alpha: 0)
                valueBubbleChart.drawValuesEnabled = true
                valueBubbleChart.valueFont = UIFont.systemFontOfSize(7)
                valueBubbleChart.valueColors = [UIColor.grayColor()]
                
                let numberFormatterValue1: NSNumberFormatter = NSNumberFormatter()
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH.mm"
                timeFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                valueString = timeFormatter.stringFromDate(nextDate)
                numberFormatterValue1.zeroSymbol = valueString
                valueBubbleChart.valueFormatter = numberFormatterValue1
                
                bubbleDataSet.append(nameBubbleChart)
                bubbleDataSet.append(valueBubbleChart)
                
                // Find the difference between the start time in graph and the event start time in minutes.
                // This value is the index of ending point of event.
                nextDate = ordinaryDateFormatter.dateFromString(eventData["endTime"]!)!
                timeIndex = calendar.components(.Minute, fromDate: startDate, toDate: nextDate, options: []).minute
                yVals.append(ChartDataEntry(value: 25, xIndex: timeIndex))
                
                let set: LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
                set.colors = [chartView.tintColor]
                set.lineWidth = 1.0
                if index == dataArray.count - 1 {
                    set.drawCirclesEnabled = false
                    set.circleRadius = 1.0
                } else {
                    set.circleRadius = 7.0
                }
                set.lineDashLengths = [5.0,5.0]
                set.drawCircleHoleEnabled = false
                set.valueFont = UIFont.systemFontOfSize(9.0)
                set.circleColors = [chartView.tintColor]
                set.drawValuesEnabled = false
                
                
                dataSet.append(set)
            default :
                break
            }
            if index == dataArray.count - 1 {
                yVals = []
                // This value is the index of ending point of event.
                nextDate = ordinaryDateFormatter.dateFromString(eventData["endTime"]!)!
                timeIndex = calendar.components(.Minute, fromDate: startDate, toDate: nextDate, options: []).minute
                yVals.append(ChartDataEntry(value: 25, xIndex: timeIndex))
                
                
                // Create a bubble below the starting point to display the end time.
                valueBubbleYVals = []
                nameBubbleYVals = []
                nameBubbleYVals.append(BubbleChartDataEntry(xIndex: timeIndex, value: 10, size: 0))
                
                let valueBubbleChart: BubbleChartDataSet = BubbleChartDataSet(yVals: nameBubbleYVals, label: "")
                valueBubbleChart.setColor(UIColor.clearColor(), alpha: 0)
                valueBubbleChart.drawValuesEnabled = true
                valueBubbleChart.valueFont = UIFont.systemFontOfSize(7)
                valueBubbleChart.valueColors = [UIColor.grayColor()]
                
                let numberFormatterValue1: NSNumberFormatter = NSNumberFormatter()
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH.mm"
                timeFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                valueString = timeFormatter.stringFromDate(nextDate)
                numberFormatterValue1.zeroSymbol = valueString
                valueBubbleChart.valueFormatter = numberFormatterValue1
                
                bubbleDataSet.append(valueBubbleChart)

                nextDate = actualEndDate
                timeIndex = calendar.components(.Minute, fromDate: startDate, toDate: nextDate, options: []).minute
                yVals.append(ChartDataEntry(value: 25, xIndex: timeIndex))

                let set: LineChartDataSet = LineChartDataSet(yVals: yVals, label: "")
                set.colors = [UIColor.grayColor()]
                set.lineWidth = 1.0
                if index == dataArray.count - 1 {
                    set.drawCirclesEnabled = false
                    set.circleRadius = 1.0
                } else {
                    set.circleRadius = 7.0
                }
                set.drawCircleHoleEnabled = false
                set.valueFont = UIFont.systemFontOfSize(9.0)
                set.circleColors = [chartView.tintColor]
                set.drawValuesEnabled = false
                
                
                // Create a bubble below the starting point to display the end time.
                valueBubbleYVals.append(BubbleChartDataEntry(xIndex: timeIndex, value: 10, size: 0))
                
                let endValueBubbleChart: BubbleChartDataSet = BubbleChartDataSet(yVals: valueBubbleYVals, label: "")
                endValueBubbleChart.setColor(UIColor.clearColor(), alpha: 0)
                endValueBubbleChart.drawValuesEnabled = true
                endValueBubbleChart.valueFont = UIFont.systemFontOfSize(7)
                endValueBubbleChart.valueColors = [UIColor.grayColor()]
                
                let numberFormatterValue: NSNumberFormatter = NSNumberFormatter()
                let timeFormatters = NSDateFormatter()
                timeFormatters.dateFormat = "HH.mm"
                timeFormatters.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                valueString = timeFormatters.stringFromDate(nextDate)
                numberFormatterValue.zeroSymbol = valueString
                endValueBubbleChart.valueFormatter = numberFormatterValue
                
                bubbleDataSet.append(endValueBubbleChart)

                dataSet.append(set)
            }
        }
        
        //        var indexArray = [Int]()
        //        indexArray.append(Int(75))
        //        indexArray.append(Int(150))
        //        indexArray.append(Int(250))
        //        indexArray.append(Int(400))
        
        //        let marker: DCGraphPoints = DCGraphPoints(color: self.chartView.tintColor, font: UIFont.systemFontOfSize(15.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0), markerIndexTextArray: indexArray)
        //        marker.minimumSize = CGSizeMake(80.0, 40.0)
        //        self.chartView.marker = marker
        
        let data: LineChartData = LineChartData(xVals: xVals, dataSets: dataSet)
        let bubbleData: BubbleChartData = BubbleChartData(xVals: xVals, dataSets: bubbleDataSet)
        
        combinedData.lineData = data
        combinedData.bubbleData = bubbleData
        
        self.chartView.data = combinedData
        
        self.chartView.setNeedsDisplay()
    }
    
    func createTemporaryGraphData () {
        let calendarStart: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendarStart.components([.Era, .Year, .Month, .Day, .Hour, .Minute], fromDate: startDate)
        comps.minute = 00
        //NSDateComponents handles rolling over between days, months, years, etc
        startDate = calendarStart.dateFromComponents(comps)!
        let firstPoint: NSDate = startDate.dateByAddingTimeInterval(60*10)
        let secondPoint: NSDate = startDate.dateByAddingTimeInterval(60 * 75)
        let thirdPoint: NSDate = startDate.dateByAddingTimeInterval(60 * 185)
        let fourthPoint: NSDate = startDate.dateByAddingTimeInterval(60 * 215)
        
        endDate = startDate.dateByAddingTimeInterval(60*301)
        let demoDateFormatter = NSDateFormatter()
        demoDateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        demoDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss xx"
        
        dataDictionary["event"] = "Started"
        dataDictionary["startTime"] = demoDateFormatter.stringFromDate(firstPoint)
        dataDictionary["endTime"] = demoDateFormatter.stringFromDate(secondPoint)
        
        dataArray.append(dataDictionary)
        
        dataDictionary["event"] = "Paused"
        dataDictionary["startTime"] = demoDateFormatter.stringFromDate(secondPoint)
        dataDictionary["endTime"] = demoDateFormatter.stringFromDate(thirdPoint)
        
        dataArray.append(dataDictionary)
        
        dataDictionary["event"] = "ReStarted"
        dataDictionary["startTime"] = demoDateFormatter.stringFromDate(thirdPoint)
        dataDictionary["endTime"] = demoDateFormatter.stringFromDate(fourthPoint)
        
        dataArray.append(dataDictionary)
        
        print(dataArray)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        NSLog("chartValueSelected")
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected")
    }
    
    func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
        print(scaleX)
    }
}
