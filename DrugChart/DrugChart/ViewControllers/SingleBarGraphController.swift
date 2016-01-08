//
//  SingleBarGraphController.swift
//  DrugChart
//
//  Created by Noureen on 07/01/2016.
//
//


import UIKit

class SingleBarGraphController: UIViewController {

    @IBOutlet weak var barGraph: BarGraphView!
    var graphData:BarGraphModel!
    var observationType:DashBoardRow!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        barGraph.plotBarGraph(graphData.xAxisValue, yAxisMinValue: graphData.yAxisMinValue, yAxisMaxValue: graphData.yAxisMaxValue, displayView: graphData.graphDisplayView, graphTitle: graphData.cellTitle, graphStartDate: graphData.graphStartDate, graphEndDate: graphData.graphEndDate, latestReadingText: graphData.latestObservationText, latestReadingDate: graphData.latestObservationDate ,noOfHorizontalLines: Constant.FULL_SCREEN_GRAPH_HORIZONTAL_LINES
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        barGraph.plotBarGraph(graphData.xAxisValue, yAxisMinValue: graphData.yAxisMinValue, yAxisMaxValue: graphData.yAxisMaxValue, displayView: graphData.graphDisplayView, graphTitle: graphData.cellTitle, graphStartDate: graphData.graphStartDate, graphEndDate: graphData.graphEndDate, latestReadingText: graphData.latestObservationText, latestReadingDate: graphData.latestObservationDate ,noOfHorizontalLines: Constant.FULL_SCREEN_GRAPH_HORIZONTAL_LINES
        )
    }

}
