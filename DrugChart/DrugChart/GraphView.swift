//
//  GrapBase.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//

import Foundation

class GraphView:UIView
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
    var margin:CGFloat = 20.0
    var maxYAxis:Double!
    var graphHeight:CGFloat!
    var topBorder:CGFloat = 60
    
    func calculateMaxXandYAxis()
    {
        switch(displayView!)
        {
        case .Day:
            maxXAxis = 24/*Hour*/ * 60 /*Minutes*/
        case .Week:
            maxXAxis = 7/*Days*/ *  24/*Hour*/ * 60 /*Minutes*/
        case .Month:
            let calendar = NSCalendar.currentCalendar()
            let noOfDays = calendar.components([.Day], fromDate: graphStartDate, toDate: graphEndDate, options: [])
            maxXAxis = noOfDays.day /*Days*/ *  24/*Hour*/ * 60 /*Minutes*/
        default:
            maxXAxis = 24/*Hour*/ * 60 /*Minutes*/
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
    
    
    func plotLineGraph(xAxisValue:[NSDate],yAxisValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate)
    {
        
    }
    
    func plotBarGraph(xAxisValue:[NSDate],yAxisMinValue:[Double],yAxisMaxValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate)
    {
        
    }
}