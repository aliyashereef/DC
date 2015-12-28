//
//  GraphCollectionViewCell.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//

import Foundation


class GraphCollectionnViewCell : UICollectionViewCell
{
    var graphView:GraphView!
    func drawLineGraph(xAxisValue:[NSDate],yAxisValue:[Double],displayView:GraphDisplayView , graphTitle:String , graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!)
    {
        graphView.plotLineGraph(xAxisValue, yAxisValue: yAxisValue ,displayView:displayView, graphTitle:graphTitle ,graphStartDate:graphStartDate , graphEndDate: graphEndDate, latestReadingText:latestReadingText , latestReadingDate:latestReadingDate)
    }
    
    func drawBarGraph(xAxisValue:[NSDate],yAxisMinValue:[Double],yAxisMaxValue:[Double],displayView:GraphDisplayView , graphTitle:String , graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!)
    {
        graphView.plotBarGraph(xAxisValue, yAxisMinValue: yAxisMinValue ,yAxisMaxValue: yAxisMaxValue ,displayView:displayView, graphTitle:graphTitle ,graphStartDate:graphStartDate , graphEndDate: graphEndDate, latestReadingText:latestReadingText , latestReadingDate:latestReadingDate)
    }
}