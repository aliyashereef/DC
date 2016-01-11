//
//  graphDelegate.swift
//  DrugChart
//
//  Created by Noureen on 06/01/2016.
//
//

import Foundation


protocol GraphDelegate
{
    func plotLineGraph(xAxisValue:[NSDate],yAxisValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!, noOfHorizontalLines:Int)
    
    func plotBarGraph(xAxisValue:[NSDate],yAxisMinValue:[Double],yAxisMaxValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!, noOfHorizontalLines:Int)
    
}

extension GraphDelegate
{
    func plotLineGraph(xAxisValue:[NSDate],yAxisValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!, noOfHorizontalLines:Int)
    {
        
    }
    
    func plotBarGraph(xAxisValue:[NSDate],yAxisMinValue:[Double],yAxisMaxValue:[Double],displayView:GraphDisplayView, graphTitle:String,graphStartDate:NSDate , graphEndDate:NSDate, latestReadingText:String! , latestReadingDate:NSDate!, noOfHorizontalLines:Int)
    {
        
    }
}