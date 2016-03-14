//
//  GrapBase.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//




class GraphView:UIView,GraphDelegate
{
    @IBInspectable var startColor:UIColor  = UIColor.redColor()
    @IBInspectable var endColor:UIColor = UIColor.greenColor()
    var maxXAxis:Int!
    var drawGraph:Bool = false
    var displayView:GraphDisplayView!
    var graphEndDate:NSDate = NSDate()
    var graphStartDate:NSDate!
    var graphTitle:String!
    var displayNoData:Bool  = false
    var width:CGFloat!
    var height:CGFloat!
    var margin:CGFloat = 20.0
    var maxYAxis:Int = 5
    var noOfLinesonxAxis = 5
    var graphHeight:CGFloat!
    var topBorderY:CGFloat = 0
    var topBorder:CGFloat = 60
    var bottomBorder:CGFloat = 50
    var latestReadingText:String!
    var latestReadingDate:NSDate!
    
    func calculateMaxXandYAxis()
    {
        switch(displayView!)
        {
        case .Day:
            maxXAxis = 24/*Hour*/ * 60 /*Minutes*/
        case .Week:
            maxXAxis = 7/*Days*/ *  24/*Hour*/ * 60 /*Minutes*/
        case .Month:
            maxXAxis = graphStartDate.getNoofDays(graphEndDate) /*Days*/ *  24/*Hour*/ * 60 /*Minutes*/
        }
        setMaxYAxis()
    }
    func setMaxYAxis()
    {}
    func columnXPoint(column:Int) -> CGFloat
    {
        let spacer = (width - margin*2 - 4) / CGFloat(self.maxXAxis - 1)
        var x:CGFloat = CGFloat(column) * spacer
        x += margin + 2
        return x
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
       let touch = touches.first!
        let location = touch.locationInView(self)
        print("Location: \(location)")
    }
    
    func columnXLabelPoint (column:Int , noOfPoints:Int) -> CGFloat
    {
        let spacer = (width - margin*2 - 4) / CGFloat(noOfPoints - 1)
        var x:CGFloat = CGFloat(column) * spacer
        x += margin + 2
        return x
    }
    
    func columnYPoint (graphPoint:Double) -> CGFloat
    {
        var y:CGFloat = CGFloat(graphPoint) / CGFloat(maxYAxis) * graphHeight
        y = graphHeight + topBorder - y // locate the point actually on the graph
        return y
    }
    func drawNormalRangeLabel()
    {
        let label = UILabel(frame: CGRectMake(0,0,200,21))
        label.center = CGPointMake(110,41 + topBorderY)
        label.textAlignment = NSTextAlignment.Left
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: label.font.fontName, size: 13)
        label.text = "Normal Range: __"
        self.addSubview(label)
    }
    func drawGraphTitle()
    {
        let label = UILabel(frame: CGRectMake(0,0,200,21))
        label.center = CGPointMake(110,20+topBorderY)
        label.textAlignment = NSTextAlignment.Left
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16.0)
        label.text = graphTitle
        self.addSubview(label)
    }
    
    func plotLineGraph(xAxisValue:[NSDate],yAxisValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!, noOfHorizontalLines:Int)
    {
        
    }
    
    func plotBarGraph(xAxisValue:[NSDate],yAxisMinValue:[Double],yAxisMaxValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate! , noOfHorizontalLines:Int)
    {
        
    }
    func  drawHorizontalLines()
    {
        // Draw lines
        let yAxisDivision = maxYAxis / noOfLinesonxAxis
        var yAxisPoint:CGFloat;
        
        let linePath = UIBezierPath()
                // first line
        for i in 0..<(noOfLinesonxAxis + 1)
        {
            // Draw a line
            yAxisPoint = columnYPoint(Double(i*yAxisDivision))
            linePath.moveToPoint(CGPoint(x:margin, y:yAxisPoint))
            linePath.addLineToPoint(CGPoint(x:width - margin,y:yAxisPoint))
            // now add the label on y Axis
            let label = UILabel(frame: CGRectMake(0,0,50,21))
            label.center = CGPointMake(width,yAxisPoint)
            label.textAlignment = NSTextAlignment.Left
            label.textColor = UIColor.whiteColor()
            label.opaque = true
            label.font = UIFont(name: label.font.fontName, size: 13)
            label.text = String(i * yAxisDivision)
            self.addSubview(label)
            
        }
        let color = UIColor (white: 1.0 , alpha: 0.3)
        color.setStroke()
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
    func drawLatestReadiongLabels()
    {
        var label = UILabel(frame: CGRectMake(0,0,150,20))
        label.center = CGPointMake(width-75,20+topBorderY)
        label.textAlignment = NSTextAlignment.Right
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(14.0)
        label.text = latestReadingText == nil ? "" : latestReadingText!
        self.addSubview(label)
        
        
        // and now the time label
        label = UILabel(frame: CGRectMake(0,0,150,20))
        label.center = CGPointMake(width-75,40+topBorderY)
        label.textAlignment = NSTextAlignment.Right
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: label.font.fontName, size: 12)
        label.text = latestReadingDate == nil ? "":latestReadingDate.getFormattedDateTime()
        self.addSubview(label)
        
    }
    func drawXAxisLabels()
    {
        switch(displayView!)
        {
        case .Day:
            for i in 0..<5
            {
                let point = columnXLabelPoint (i,noOfPoints: 5)
                let label = UILabel(frame: CGRectMake(0,0,200,21))
                label.center = CGPointMake(point, height - (bottomBorder/2))
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                label.font = UIFont(name: label.font.fontName, size: 13)
                switch(i)
                {
                case 0:
                    label.text = "12 am"
                case 1:
                    label.text = "6 am"
                case 2:
                    label.text = "12 pm"
                case 3:
                    label.text = "6 pm"
                default:
                    label.text = ""
                }
                //label.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.addSubview(label)
            }
        case .Week:
            
            var weekDate:NSDate = graphStartDate!
            var count:Int = 0
            
            for i in 0..<8  // 7 days a week
            {
                let point = columnXLabelPoint (i,noOfPoints: 7)
                let label = UILabel(frame: CGRectMake(0,0,200,21))
                label.center = CGPointMake(point, height - (bottomBorder/2))
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                label.font = UIFont(name: label.font.fontName, size: 13)
                label.text = (count % 6 == 0) ? weekDate.getFormatedDayandMonth() : weekDate.getFormattedDay()
                weekDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Day,
                    value: 1,
                    toDate:weekDate ,
                    options: NSCalendarOptions(rawValue: 0))!
                count++;
                self.addSubview(label)
            }
        case .Month:
            var weekDate:NSDate = graphStartDate!
            let noOfDays:Int = graphStartDate.getNoofDays(graphEndDate)
            var count:Int = 0
            for i in 0..<noOfDays+1  // 7 days a week
            {
                if (count % 7 == 0)
                {
                    let point = columnXLabelPoint (i,noOfPoints: noOfDays)
                    let label = UILabel(frame: CGRectMake(0,0,200,21))
                    label.center = CGPointMake(point, height - (bottomBorder/2))
                    label.textAlignment = NSTextAlignment.Center
                    label.textColor = UIColor.whiteColor()
                    label.font = UIFont(name: label.font.fontName, size: 13)
                    let calendar = NSCalendar.currentCalendar()
                    let chosenDateComponents = calendar.components([.Day,.Month], fromDate: weekDate)
                    label.text = String(format: "%d/%d",chosenDateComponents.day,chosenDateComponents.month)
                    label.text = weekDate.getFormatedDayandMonth()
                    self.addSubview(label)
                }
                count++
                weekDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Day,
                    value: 1,
                    toDate:weekDate ,
                    options: NSCalendarOptions(rawValue: 0))!
            }
        }
    }
}