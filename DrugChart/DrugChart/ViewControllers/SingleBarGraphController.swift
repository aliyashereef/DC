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
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Observation Trend"
        // Do any additional setup after loading the view.
        barGraph.plotBarGraph(graphData.xAxisValue, yAxisMinValue: graphData.yAxisMinValue, yAxisMaxValue: graphData.yAxisMaxValue, displayView: graphData.graphDisplayView, graphTitle: graphData.cellTitle, graphStartDate: graphData.graphStartDate, graphEndDate: graphData.graphEndDate, latestReadingText: graphData.latestObservationText, latestReadingDate: graphData.latestObservationDate ,noOfHorizontalLines: Constant.FULL_SCREEN_GRAPH_HORIZONTAL_LINES
        )
        setDateLabel()
    }
    
    
    func setDateLabel()
    {
        switch(graphData.graphDisplayView!)
        {
        case GraphDisplayView.Day:
            dateLabel.text = graphData.graphStartDate.getFormattedDate()
        default:
            dateLabel.text = String(format:"%@ - %@", graphData.graphStartDate.getFormattedDate() , graphData.graphEndDate.getFormattedDate())
        }
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
