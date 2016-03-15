//
//  GraphView.swift
//  DrugChart
//
//  Created by Noureen on 03/12/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import UIKit

@IBDesignable class LineGraphView: GraphView {

    private var xAxisValue:[NSDate]!
    private var yAxisValue:[Double]!
    
    
    var observationDelegate:ObservationDelegate? = nil
    
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
                var startPoint = CGPoint.zero
                var endPoint = CGPoint(x:0,y:self.bounds.height )
                CGContextDrawLinearGradient(context, gradient,startPoint,endPoint,CGGradientDrawingOptions(rawValue: 0))
                
                /// now draw the line
                
                UIColor.whiteColor().setFill()
                UIColor.whiteColor().setStroke()
                
                
                //Draw the graph Title
                drawGraphTitle()
                //Draw the normal range
                drawNormalRangeLabel()
                
                if(xAxisValue.count == 0 || yAxisValue.count == 0)
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
    
    
            // setup the point line
            let graphPath = UIBezierPath()
            graphPath.lineWidth = 0.5
            //go to the start of line
                graphPath.moveToPoint(CGPoint(x:columnXPoint(xAxisValue[0].getDatePart(self.displayView,startDate:graphStartDate)),y:columnYPoint(yAxisValue[0])))
    
            //add points for each item in the graphPoints array
            for i in 1..<yAxisValue.count {
                let nextPoint = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(self.displayView,startDate:graphStartDate)) , y:columnYPoint(yAxisValue[i]))
                graphPath.addLineToPoint(nextPoint)
            }
             graphPath.stroke() // just for testing purpose.
                
            // add gradient to the graph
            if(yAxisValue.count > 1)// draw the gradient if there is more than one items.
            {
            
                // create the clipping path for the graph gradient
            //1) save the state of current context
            CGContextSaveGState(context)
    
            //2)make a copy of the path
            let clippingPath = graphPath.copy() as! UIBezierPath
    
            //3)Add lines to the copied Path to complete the clip area.
            clippingPath.addLineToPoint(CGPoint(x:columnXPoint( maxXAxis) , y:height))
            clippingPath.addLineToPoint(CGPoint(x:columnXPoint(xAxisValue[0].getDatePart(self.displayView,startDate:graphStartDate)),y:height))
            clippingPath.closePath()
    
            //4) add clipping path to the context
    
            clippingPath.addClip()
    
           
            
            let highestYPoint = columnYPoint(yAxisValue.maxElement()!)
            startPoint = CGPoint(x:margin , y:highestYPoint)
            endPoint = CGPoint(x:margin , y: self.bounds.height)
    
            CGContextDrawLinearGradient(context,gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
            CGContextRestoreGState(context)
    
            graphPath.lineWidth = 2.0
            graphPath.stroke()
                }
                
            // draw the circle dots on the graph
//            for i in 0..<yAxisValue.count
//            {
//                var point = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(displayView,startDate:graphStartDate)) , y:columnYPoint(yAxisValue[i]))
//                point.x -= 5.0/2
//                point.y -= 5.0/2
//                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 5.0,height: 5.0)))
//                circle.fill()
//            }

                
                
            for i in 0..<yAxisValue.count
            {
                let point = CGPoint(x:columnXPoint(xAxisValue[i].getDatePart(displayView,startDate:graphStartDate)) , y:columnYPoint(yAxisValue[i]))
                
                let dot = UIButton(type: UIButtonType.Custom) as UIButton
                dot.frame = CGRect(origin: point, size: CGSize(width: 20.0,height: 20.0))
                dot.setImage(UIImage(named:"graphDot" as String)!, forState: UIControlState.Normal)
                dot.center = point
                dot.tag = i // save the item number in tag so that later on you can access the records.
                dot.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
                self.addSubview(dot)
            }

                
            drawHorizontalLines()
            // add last entered label
            drawLatestReadiongLabels()
            // now add the label on the UI
            drawXAxisLabels()
           
             // set the bit false again to be used next time
                self.drawGraph = false
            }
        }

    
    
    func btnTouched(sender:AnyObject)
   {
    let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
    let tooltipViewController : TooltipViewController = (mainStoryboard.instantiateViewControllerWithIdentifier("ToolTip") as? TooltipViewController)!
    let senderButton = sender as? UIButton
    let tooltiptext = String("(\(yAxisValue[senderButton!.tag]),\(xAxisValue[senderButton!.tag].getFormattedDateTime()))")
    tooltipViewController.toolTipText = tooltiptext
    tooltipViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
    if let popover = tooltipViewController.popoverPresentationController
    {
        let viewForSource = sender as! UIView
        popover.sourceView = viewForSource
        
        // the position of the popover where it's showed
        popover.sourceRect = viewForSource.bounds
        
        // the size you want to display
        tooltipViewController.preferredContentSize = CGSizeMake(300,70)
       // popover.delegate = self
    }
    
    observationDelegate?.ShowPopOver(tooltipViewController)
    
    }
   override func setMaxYAxis() {
        if(self.yAxisValue != nil && self.yAxisValue.count>0)
        {
            self.maxYAxis = Int(ceil (yAxisValue.maxElement()!))
            while( self.maxYAxis%self.noOfLinesonxAxis != 0)
            {
                self.maxYAxis++
            }
        }
    }
    
    
    override func plotLineGraph(xAxisValue:[NSDate],yAxisValue:[Double], displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate , latestReadingText:String! , latestReadingDate:NSDate!,noOfHorizontalLines:Int) {
        self.maxXAxis = noOfHorizontalLines
        self.noOfLinesonxAxis = noOfHorizontalLines
        self.graphStartDate = graphStartDate
        self.graphEndDate = graphEndDate
        self.xAxisValue = xAxisValue
        self.yAxisValue = yAxisValue
        self.graphTitle = graphTitle
        self.latestReadingText = latestReadingText
        self.latestReadingDate = latestReadingDate
        self.drawGraph = true
        self.displayView = displayView
        calculateMaxXandYAxis()
        self.setNeedsDisplay()
    }
}


