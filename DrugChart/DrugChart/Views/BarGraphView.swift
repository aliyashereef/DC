//
//  BarGraphView.swift
//  Drug Chart
//
//  Created by Noureen on 04/12/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

class BarGraphView: GraphView {
//        var graphPoints:[Int] = [8,9,10,12,14]  // yAxisMaxValue  // they are actually y axis values
//        var graphYPoint:[Int] = [2,3,4,6,5]    // yAxisMinValue
//    
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
                let startPoint = CGPoint.zero
                let endPoint = CGPoint(x:0,y:self.bounds.height )
                CGContextDrawLinearGradient(context, gradient,startPoint,endPoint,CGGradientDrawingOptions(rawValue: 0))
                
                /// now draw the line
                
                UIColor.whiteColor().setFill()
                UIColor.whiteColor().setStroke()
                
                
                //Draw the graph Title
                let label = UILabel(frame: CGRectMake(0,0,200,21))
                label.center = CGPointMake(70,20)
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                //label.font =UIFont(name: label.font.fontName, size: 17)
                label.font = UIFont.boldSystemFontOfSize(16.0)
                label.text = graphTitle
                self.addSubview(label)
                
                
                
                if(xAxisValue.count == 0 || yAxisMaxValue.count == 0)
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
      
            // calculate the y points
            let topBorder:CGFloat = 60
            let bottomBorder:CGFloat = 50
            graphHeight = height - topBorder - bottomBorder
            
            /// now draw the line
    
            UIColor.whiteColor().setFill()
            UIColor.whiteColor().setStroke()
    
            // setup the point line
            let graphPath = UIBezierPath()
            for i in 0..<yAxisMaxValue.count
            {
                var nextPoint = CGPoint(x:columnXPoint(i),y:columnYPoint(yAxisMaxValue[i]))
                graphPath.moveToPoint(nextPoint)
                nextPoint = CGPoint(x:columnXPoint(i) , y:columnYPoint(yAxisMinValue[i]))
                graphPath.addLineToPoint(nextPoint)
            }
    
            graphPath.stroke()
    //
            // draw the circle dots on the graph
            for i in 0..<yAxisMaxValue.count
            {
                var point = CGPoint(x:columnXPoint(i) , y:columnYPoint(yAxisMaxValue[i]))
                point.x -= 5.0/2
                point.y -= 5.0/2
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5.0,height: 5.0)))
                //let circle = UIBezierPath(arcCenter: point, radius: 2.5, startAngle: 0, endAngle: 360, clockwise: true)
                circle.stroke()
                //circle.fill()
            }
            
            for i in 0..<yAxisMinValue.count
            {
                var point = CGPoint(x:columnXPoint(i) , y:columnYPoint(yAxisMinValue[i]))
                point.x -= 5.0/2
                point.y -= 5.0/2
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5.0,height: 5.0)))
                circle.fill()
            }
        }
    }
    
    override func setMaxYAxis() {
        if(self.yAxisMaxValue != nil && self.yAxisMaxValue.count>0)
        {
            self.maxYAxis = yAxisMaxValue.maxElement()
        }
    }
    
    override func plotBarGraph(xAxisValue:[NSDate],yAxisMinValue:[Double],yAxisMaxValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate)
    {
            self.graphStartDate = graphStartDate
            self.graphEndDate = graphEndDate
            self.xAxisValue = xAxisValue
            self.yAxisMinValue = yAxisMinValue
            self.yAxisMaxValue = yAxisMaxValue
            self.graphTitle = graphTitle
            self.drawGraph = true
            self.displayView = displayView
            calculateMaxXandYAxis()
        
            self.setNeedsDisplay()
        
    }
    
}

