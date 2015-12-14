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
    func drawGraph(xAxisValue:[NSDate],yAxisValue:[Double],displayView:GraphDisplayView , graphTitle:String)
    {
        graphView.plot(xAxisValue, yAxisValue: yAxisValue ,displayView:displayView, graphTitle:graphTitle )
    }
}