//
//  BarGraphView.swift
//  Drug Chart
//
//  Created by Noureen on 04/12/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

class BarGraphView: GraphView {
    
    private var xAxisValue:[NSDate]!
    private var yAxisMinValue:[Double]!
    private var yAxisMaxValue:[Double]!
    
        override func drawRect(rect: CGRect) {
            
            for subUIView in self.subviews {
                subUIView.removeFromSuperview()
            }
            if (self.drawGraph)
            {
                width = self.frame.width
                height = self.frame.height
                topBorderY = self.frame.origin.y
                topBorder = 60 + topBorderY
                
                // Draw the graph background
                let path = UIBezierPath(roundedRect: self.frame, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 8.0, height: 8.0))
                
                path.addClip()
                
                let context = UIGraphicsGetCurrentContext()
                CGContextSetShouldAntialias(context, true)
                let colors = [startColor.CGColor , endColor.CGColor ]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                
                let coreLocations:[CGFloat] = [0.0, 1.0]
                let gradient  = CGGradientCreateWithColors(colorSpace,colors, coreLocations)
                let startPoint = CGPoint.zero
                let endPoint = CGPoint(x:0,y:self.bounds.height )
                CGContextDrawLinearGradient(context, gradient,startPoint,endPoint,CGGradientDrawingOptions(rawValue: 0))
                
                /// now draw the line
                
                UIColor.whiteColor().setFill()
                UIColor.whiteColor().setStroke()
                
                
                //Draw the graph Title
                drawGraphTitle()
                
                //Draw Normal Range Label
                
                if(xAxisValue.count == 0 || yAxisMaxValue.count == 0)
                {
                    let label = UILabel(frame: CGRectMake(0,0,200,21))
                    label.center = CGPointMake(width/2,height/2)
                    label.textAlignment = NSTextAlignment.Center
                    label.textColor = UIColor.whiteColor()
                    label.text = "No Data"
                    self.addSubview(label)
                    // set the bit false again to be used next time
                    self.drawGraph = false
                    
                    return
                }
      
            // calculate the y points
            graphHeight = height - topBorder - bottomBorder
            
            /// now draw the line
    
            UIColor.whiteColor().setFill()
            UIColor.whiteColor().setStroke()
    
            // setup the point line
            let graphPath = UIBezierPath()
            for i in 0..<yAxisMaxValue.count
            {
                let xAxis = columnXPoint(xAxisValue[i].getDatePart(self.displayView,startDate:graphStartDate))
                var nextPoint = CGPoint(x:xAxis,y:columnYPoint(yAxisMaxValue[i]))
                graphPath.moveToPoint(nextPoint)
                nextPoint = CGPoint(x:xAxis , y:columnYPoint(yAxisMinValue[i]))
                graphPath.addLineToPoint(nextPoint)
            }
    
            graphPath.stroke()
            // draw the circle dots on the graph
//            for i in 0..<yAxisMaxValue.count
//            {
//                var point = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(self.displayView,startDate:graphStartDate)) , y:columnYPoint(yAxisMaxValue[i]))
//                point.x -= 5.0/2
//                point.y -= 5.0/2
//                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5.0,height: 5.0)))
//                circle.stroke()
//            }
//            
//            for i in 0..<yAxisMinValue.count
//            {
//                var point = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(self.displayView,startDate:graphStartDate)) , y:columnYPoint(yAxisMinValue[i]))
//                point.x -= 5.0/2
//                point.y -= 5.0/2
//                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5.0,height: 5.0)))
//                circle.fill()
//            }
                
                // draw the button instead to have some events on
                // draw diastolic
                for i in 0..<yAxisMaxValue.count
                {
                    let point = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(self.displayView,startDate:graphStartDate)) , y:columnYPoint(yAxisMaxValue[i]))
                    
                    let dot = UIButton(type: UIButtonType.Custom) as UIButton
                    dot.frame = CGRect(origin: point, size: CGSize(width: 16.0,height: 16.0))
                    dot.setImage(UIImage(named:"whiteDot" as String)!, forState: UIControlState.Normal)
                    dot.center = point
                    dot.tag = i // save the item number in tag so that later on you can access the records.
                    dot.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
                    self.addSubview(dot)
                }
                
                for i in 0..<yAxisMinValue.count
                {
                    let point = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(self.displayView,startDate:graphStartDate)) , y:columnYPoint(yAxisMinValue[i]))
                    
                    let dot = UIButton(type: UIButtonType.Custom) as UIButton
                    dot.frame = CGRect(origin: point, size: CGSize(width: 16.0,height: 16.0))
                    dot.setImage(UIImage(named:"blackDot" as String)!, forState: UIControlState.Normal)
                    dot.center = point
                    dot.tag = i // save the item number in tag so that later on you can access the records.
                    dot.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
                    self.addSubview(dot)
                }
                // draw the horizontal lines
                drawHorizontalLines()
                // now add the label on the UI
                drawLatestReadiongLabels()
                drawXAxisLabels()
                self.drawGraph = false
                
        }
    }
    
    override func getToolTip(tag: Int) -> String {
        return String("(\(yAxisMaxValue[tag]) / \(yAxisMinValue[tag]) ,\(xAxisValue[tag].getFormattedDateTime()))")
    }
    override func setMaxYAxis() {
        if(self.yAxisMaxValue != nil && self.yAxisMaxValue.count>0)
        {
            self.maxYAxis = Int(yAxisMaxValue.maxElement()!)
        }
    }
    
    override func plotBarGraph(xAxisValue:[NSDate],yAxisMinValue:[Double],yAxisMaxValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!, noOfHorizontalLines:Int)
    {
            self.maxXAxis = noOfHorizontalLines
            self.noOfLinesonxAxis = noOfHorizontalLines
            self.graphStartDate = graphStartDate
            self.graphEndDate = graphEndDate
            self.xAxisValue = xAxisValue
            self.yAxisMinValue = yAxisMinValue
            self.yAxisMaxValue = yAxisMaxValue
            self.graphTitle = graphTitle
            self.latestReadingText = latestReadingText
            self.latestReadingDate = latestReadingDate
            self.drawGraph = true
            self.displayView = displayView
            calculateMaxXandYAxis()
            self.setNeedsDisplay()
    }
    
}

