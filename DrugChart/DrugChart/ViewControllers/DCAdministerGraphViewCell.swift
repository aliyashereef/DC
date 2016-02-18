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

    @IBOutlet weak var chartView: CombinedChartView!
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
        self.chartView.xAxis.axisLineWidth = 0
        self.chartView.xAxis.gridColor = UIColor.grayColor()
        
        self.chartView.viewPortHandler.setMaximumScaleY(1)
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
        let firstPoint: NSDate = startDate.dateByAddingTimeInterval(60*10)
        let lastPoint: NSDate = firstPoint.dateByAddingTimeInterval(60 * 221)
        print(firstPoint)
        print(lastPoint)
        
        let minutesToAdd: Int = 1
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components: NSDateComponents = NSDateComponents()
        components.minute = minutesToAdd

        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM \n HH:mm"
        let xAxiS: ChartXAxis = self.chartView.xAxis
        xAxiS.labelFont = UIFont.systemFontOfSize(9)
        xAxiS.labelTextColor = UIColor.grayColor()
        xAxiS.setLabelsToSkip(3)
        var i: Int = 0
        while i <= 301 {
            let stringFromDate: String = dateFormatter.stringFromDate(startDate)
            startDate = calendar.dateByAddingComponents(components, toDate: startDate, options: NSCalendarOptions.MatchFirst)!
            xVals.append(stringFromDate)
            i++
        }
        self.chartView.extraTopOffset = 24
        self.chartView.extraLeftOffset = 85
        self.chartView.extraRightOffset = 85
        self.chartView.extraBottomOffset = 15
        self.chartView.xAxis.axisLabelModulus = 60

        var yVals1 = [ChartDataEntry]()
//        var yVals2 = [ChartDataEntry]()
//        var yVals3 = [ChartDataEntry]()

        
        yVals1.append(ChartDataEntry(value: 25, xIndex: 10))
        yVals1.append(ChartDataEntry(value: 25, xIndex: 231))
//        yVals2.append(ChartDataEntry(value: 25, xIndex: 150))
//        yVals2.append(ChartDataEntry(value: 25, xIndex: 250))
//        yVals3.append(ChartDataEntry(value: 25, xIndex: 250))
//        yVals3.append(ChartDataEntry(value: 25, xIndex: 400))

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
        set1.lineWidth = 1.0
        set1.circleRadius = 7.0
        set1.drawCircleHoleEnabled = false
        set1.valueFont = UIFont.systemFontOfSize(9.0)
        set1.circleColors = [chartView.tintColor]
        set1.drawValuesEnabled = false

//        let set2: LineChartDataSet = LineChartDataSet(yVals: yVals2, label: "")
//        set2.lineDashLengths = [5.0, 5.0]
//        set2.colors = [chartView.tintColor]
//        set2.circleColors = [chartView.tintColor]
//        set2.lineWidth = 4.0
//        set2.circleRadius = 5.0
//        set2.drawCircleHoleEnabled = false
//        set2.valueFont = UIFont.systemFontOfSize(9.0)
//        set2.drawValuesEnabled = false
//
//        let set3: LineChartDataSet = LineChartDataSet(yVals: yVals3, label: "")
//        set3.colors = [chartView.tintColor]
//        set3.lineWidth = 4.0
//        set3.circleRadius = 5.0
//        set3.drawCircleHoleEnabled = false
//        set3.valueFont = UIFont.systemFontOfSize(9.0)
//        set3.drawValuesEnabled = false
//        set3.circleColors = [chartView.tintColor]
        
        
        var dataSets = [ChartDataSet]()
        dataSets.append(set1)
//        dataSets.append(set2)
//        dataSets.append(set3)
        let data: LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
//        self.chartView.data = data
        
        let combinedData: CombinedChartData = CombinedChartData(xVals: xVals)
        combinedData.lineData = data
//        combinedData.barData = self.generateBarData()
        
        var yValsBubble1 = [BubbleChartDataEntry]()
        var yValsBubble2 = [BubbleChartDataEntry]()
        var yValsBubble1Value = [BubbleChartDataEntry]()
        var yValsBubble2Value = [BubbleChartDataEntry]()

        yValsBubble1.append(BubbleChartDataEntry(xIndex: 10, value: 25, size: 0))
        yValsBubble2.append(BubbleChartDataEntry(xIndex: 231, value: 25, size: 0))
        yValsBubble1Value.append(BubbleChartDataEntry(xIndex: 10, value: 15, size: 0))
        yValsBubble2Value.append(BubbleChartDataEntry(xIndex: 231, value: 15, size: 0))


        let setBubble1: BubbleChartDataSet = BubbleChartDataSet(yVals: yValsBubble1, label: "")
        setBubble1.setColor(chartView.tintColor, alpha: 1)
        setBubble1.drawValuesEnabled = true
        setBubble1.valueFont = UIFont.systemFontOfSize(9)
        setBubble1.valueColors = [UIColor.whiteColor()]
        
        let numberFormatterS: NSNumberFormatter = NSNumberFormatter()
        numberFormatterS.zeroSymbol = "S"
        setBubble1.valueFormatter = numberFormatterS
        
        let setBubble2: BubbleChartDataSet = BubbleChartDataSet(yVals: yValsBubble2, label: "")
        setBubble2.setColor(chartView.tintColor, alpha: 1)
        setBubble2.drawValuesEnabled = true
        setBubble2.valueFont = UIFont.systemFontOfSize(9)
        setBubble2.valueColors = [UIColor.whiteColor()]
        
        let numberFormatterE: NSNumberFormatter = NSNumberFormatter()
        numberFormatterE.zeroSymbol = "E"
        setBubble2.valueFormatter = numberFormatterE
        
        let setBubble1Value: BubbleChartDataSet = BubbleChartDataSet(yVals: yValsBubble1Value, label: "")
        setBubble1Value.setColor(UIColor.clearColor(), alpha: 0)
        setBubble1Value.drawValuesEnabled = true
        setBubble1Value.valueFont = UIFont.systemFontOfSize(9)
        setBubble1Value.valueColors = [UIColor.grayColor()]
        
        let numberFormatterValue1: NSNumberFormatter = NSNumberFormatter()
        numberFormatterValue1.zeroSymbol = "6.10"
        setBubble1Value.valueFormatter = numberFormatterValue1

        let setBubble2Value: BubbleChartDataSet = BubbleChartDataSet(yVals: yValsBubble2Value, label: "")
        setBubble2Value.setColor(UIColor.clearColor(), alpha: 0)
        setBubble2Value.drawValuesEnabled = true
        setBubble2Value.valueFont = UIFont.systemFontOfSize(9)
        setBubble2Value.valueColors = [UIColor.grayColor()]
        
        let numberFormatterValue2: NSNumberFormatter = NSNumberFormatter()
        numberFormatterValue2.zeroSymbol = "9.51"
        setBubble2Value.valueFormatter = numberFormatterValue2

        var dataSetsBubble = [ChartDataSet]()
        dataSetsBubble.append(setBubble1)
        dataSetsBubble.append(setBubble2)
        dataSetsBubble.append(setBubble1Value)
        dataSetsBubble.append(setBubble2Value)

        let dataBubble: BubbleChartData = BubbleChartData(xVals: xVals, dataSets: dataSetsBubble)
        //        dataBubble.valueFont(UIFont(name: "HelveticaNeue-Light", size: 7.0))
        //        dataBubble.highlightCircleWidth = 1.5
        //        dataBubble.valueTextColor = UIColor.whiteColor
        //        self.chartView.data = dataBubble

        combinedData.bubbleData = dataBubble
        //data.scatterData = [self generateScatterData];
        //data.candleData = [self generateCandleData];
        self.chartView.data = combinedData
        self.chartView.setNeedsDisplay()
        
    }
}
