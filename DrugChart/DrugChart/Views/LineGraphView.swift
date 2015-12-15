//
//  GraphView.swift
//  DrugChart
//
//  Created by Noureen on 03/12/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

@IBDesignable class LineGraphView: GraphView {

    @IBInspectable var startColor:UIColor  = UIColor.redColor()
    @IBInspectable var endColor:UIColor = UIColor.greenColor()
    //var graphPoints:[Int] = [4,6,4,5,8,3,10]   // they are actually y axis values
    //var xAxisPoints:[Int] = [60,180,300,420,480,600,690]
    private var xAxisValue:[NSDate]!
    private var yAxisValue:[Double]!
    var maxXAxis:Int! // by default assume that it is day only graph
    var drawGraph:Bool = false
    var displayView:GraphDisplayView!
    var graphDate:NSDate = NSDate()
    var startDate:NSDate!
    var graphTitle:String!
    var displayNoData:Bool  = false
    
        override func drawRect(rect: CGRect) {
            
            for subUIView in self.subviews {
                subUIView.removeFromSuperview()
            }
            if (self.drawGraph)
            {
                let width = self.frame.width
                let height = self.frame.height
                
                // Draw the graph background
                let path = UIBezierPath(roundedRect: self.frame, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 8.0, height: 8.0))
                
                path.addClip()
                
                let context = UIGraphicsGetCurrentContext()
                CGContextSetShouldAntialias(context, true)
                let colors = [startColor.CGColor , endColor.CGColor ]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                
                let coreLocations:[CGFloat] = [0.0, 1.0]
                let gradient  = CGGradientCreateWithColors(colorSpace,colors, coreLocations)
                var startPoint = CGPoint.zero
                var endPoint = CGPoint(x:0,y:self.bounds.height )
                CGContextDrawLinearGradient(context, gradient,startPoint,endPoint,CGGradientDrawingOptions(rawValue: 0))
                
                /// now draw the line
                
                UIColor.whiteColor().setFill()
                UIColor.whiteColor().setStroke()
                
                
                //Draw the graph Title
                let label = UILabel(frame: CGRectMake(0,0,200,21))
                label.center = CGPointMake(50,20)
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                //label.font =UIFont(name: label.font.fontName, size: 17)
                label.font = UIFont.boldSystemFontOfSize(16.0)
                label.text = graphTitle
                self.addSubview(label)
                
                
                
                if(xAxisValue.count == 0 || yAxisValue.count == 0)
            {
                
                //let point = 10
                let label = UILabel(frame: CGRectMake(0,0,200,21))
                label.center = CGPointMake(height/2,width/2)
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                label.text = "No Data"
                self.addSubview(label)
                // set the bit false again to be used next time
                self.drawGraph = false
                
                return
            }
                
       
            // calculate x point
            let margin:CGFloat = 20.0
    
    
            let columnXPoint = {(column:Int) -> CGFloat in
                let spacer = (width - margin*2 - 4) / CGFloat(self.maxXAxis - 1)
                var x:CGFloat = CGFloat(column) * spacer
                x += margin + 2
                return x
            }
    
            let columnXLabelPoint = {(column:Int , noOfPoints:Int) -> CGFloat in
                let spacer = (width - margin*2 - 4) / CGFloat(noOfPoints - 1)
                var x:CGFloat = CGFloat(column) * spacer
                x += margin + 2
                return x
            }
    
            // calculate the y points
            let topBorder:CGFloat = 60
            let bottomBorder:CGFloat = 50
            let graphHeight = height - topBorder - bottomBorder
            let maxValue = yAxisValue.maxElement()!
            let columnYPoint = { (graphPoint:Double) -> CGFloat in
                var y:CGFloat = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
                y = graphHeight + topBorder - y // locate the point actually on the graph
                return y
            }
    
    
            // setup the point line
            let graphPath = UIBezierPath()
            graphPath.lineWidth = 0.5
            //go to the start of line
                graphPath.moveToPoint(CGPoint(x:columnXPoint(xAxisValue[0].getDatePart(self.displayView,startDate:startDate)),y:columnYPoint(yAxisValue[0])))
    
            //add points for each item in the graphPoints array
            for i in 1..<yAxisValue.count {
                let nextPoint = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(self.displayView,startDate:startDate)) , y:columnYPoint(yAxisValue[i]))
                graphPath.addLineToPoint(nextPoint)
            }
            // graphPath.stroke() // just for testing purpose.
                
            // add gradient to the graph
    
            // create the clipping path for the graph gradient
            //1) save the state of current context
            CGContextSaveGState(context)
    
            //2)make a copy of the path
            let clippingPath = graphPath.copy() as! UIBezierPath
    
            //3)Add lines to the copied Path to complete the clip area.
            clippingPath.addLineToPoint(CGPoint(x:columnXPoint( maxXAxis) , y:height))
            clippingPath.addLineToPoint(CGPoint(x:columnXPoint(xAxisValue[0].getDatePart(self.displayView,startDate:startDate)),y:height))
            clippingPath.closePath()
    
            //4) add clipping path to the context
    
            clippingPath.addClip()
    
            //5) check clipping path temporary code
            //        UIColor.greenColor().setFill()
            //        let rectPath = UIBezierPath(rect: self.bounds)
            //        rectPath.fill()
    
            let highestYPoint = columnYPoint(maxValue)
            startPoint = CGPoint(x:margin , y:highestYPoint)
            endPoint = CGPoint(x:margin , y: self.bounds.height)
    
            CGContextDrawLinearGradient(context,gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
            CGContextRestoreGState(context)
    
            graphPath.lineWidth = 2.0
            graphPath.stroke()
    
            // draw the circle dots on the graph
            for i in 0..<yAxisValue.count
            {
                var point = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(displayView,startDate:startDate)) , y:columnYPoint(yAxisValue[i]))
                point.x -= 5.0/2
                point.y -= 5.0/2
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5.0,height: 5.0)))
                circle.fill()
            }
            // draw the horizontal lines
            let linePath = UIBezierPath()
            // top line
            linePath.moveToPoint(CGPoint(x:margin,y:topBorder))
            linePath.addLineToPoint(CGPoint(x:width-margin , y:topBorder))
            // center line
            linePath.moveToPoint(CGPoint(x:margin, y:graphHeight/2 + topBorder))
            linePath.addLineToPoint(CGPoint(x:width-margin , y:graphHeight/2 + topBorder))
            // bottom line
            linePath.moveToPoint(CGPoint(x:margin, y:height - bottomBorder))
            linePath.addLineToPoint(CGPoint(x:width - margin,y:height - bottomBorder))
            let color = UIColor (white: 1.0 , alpha: 0.3)
            color.setStroke()
            linePath.lineWidth = 1.0
            linePath.stroke()
    
            
            // now add the label on the UI
            switch(displayView!)
            {
            case .Day:
                for i in 0..<5
                {
                    let point = columnXLabelPoint (i,5)
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
                
                var weekDate:NSDate = startDate!
                for i in 0..<8  // 7 days a week
                {
                    let point = columnXLabelPoint (i,7)
                    let label = UILabel(frame: CGRectMake(0,0,200,21))
                    label.center = CGPointMake(point, height - (bottomBorder/2))
                    label.textAlignment = NSTextAlignment.Center
                    label.textColor = UIColor.whiteColor()
                    label.font = UIFont(name: label.font.fontName, size: 13)
                    let calendar = NSCalendar.currentCalendar()
                    let chosenDateComponents = calendar.components([.Day,.Month], fromDate: weekDate)
                    
                    label.text = String(format: "%d/%d",chosenDateComponents.day,chosenDateComponents.month)
                    weekDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Day,
                    value: 1,
                    toDate:weekDate ,
                    options: NSCalendarOptions(rawValue: 0))!
                    self.addSubview(label)
                }
            case .Month:
                return
            default:
                print("no label")
            }
          
            
           
             // set the bit false again to be used next time
                self.drawGraph = false
            }
        }
  
    func calculateMaxXAxis()
    {
        switch(displayView!)
        {
            case .Day:
                maxXAxis = 24/*Hour*/ * 60 /*Minutes*/
            case .Week:
                maxXAxis = 7/*Days*/ *  24/*Hour*/ * 60 /*Minutes*/
        case .Month:
                maxXAxis = 7/*Days*/ *  24/*Hour*/ * 60 /*Minutes*/
            default:
             maxXAxis = 24/*Hour*/ * 60 /*Minutes*/
            
        }
    }
    
    func setGraphStartDate()
    {
        switch(displayView!)
        {
            case .Day:
                startDate = NSDate()
            case .Week:
                startDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Day,
                value: -6,
                toDate:graphDate ,
                options: NSCalendarOptions(rawValue: 0))
            default:
                startDate = NSDate()
        }
    }
    
    override func plot(xAxisValue:[NSDate],yAxisValue:[Double], displayView:GraphDisplayView, graphTitle:String,graphDate:NSDate) {
        self.graphDate = graphDate
        self.xAxisValue = xAxisValue
        self.yAxisValue = yAxisValue
        self.graphTitle = graphTitle
        self.drawGraph = true
        self.displayView = displayView
        setGraphStartDate()
        calculateMaxXAxis()
        self.setNeedsDisplay()
    }
}


