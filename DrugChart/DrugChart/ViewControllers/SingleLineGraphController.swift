//
//  SingleLineGraphController.swift
//  DrugChart
//
//  Created by Noureen on 06/01/2016.
//
//

import UIKit

class SingleLineGraphController: UIViewController , ObservationDelegate,UIPopoverPresentationControllerDelegate  {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var lineGraph: LineGraphView!
    var graphData:LineGraphModel!
    var observationType:DashBoardRow!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Observation Trend"
        // Do any additional setup after loading the view.
        lineGraph.plotLineGraph(graphData.xAxisValue, yAxisValue: graphData.yAxisValue, displayView: graphData.graphDisplayView, graphTitle: graphData.cellTitle, graphStartDate: graphData.graphStartDate, graphEndDate: graphData.graphEndDate, latestReadingText: graphData.latestObservationText, latestReadingDate: graphData.latestObservationDate ,noOfHorizontalLines: Constant.FULL_SCREEN_GRAPH_HORIZONTAL_LINES
           )
        lineGraph.observationDelegate = self
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
   
    lineGraph.plotLineGraph(graphData.xAxisValue, yAxisValue: graphData.yAxisValue, displayView: graphData.graphDisplayView, graphTitle: graphData.cellTitle, graphStartDate: graphData.graphStartDate, graphEndDate: graphData.graphEndDate, latestReadingText: graphData.latestObservationText, latestReadingDate: graphData.latestObservationDate,noOfHorizontalLines: Constant.FULL_SCREEN_GRAPH_HORIZONTAL_LINES)
}
    
    func ShowPopOver(viewController: UIViewController)
    {
        if let popover = viewController.popoverPresentationController {
            popover.delegate = self
        }
        self.presentViewController(viewController, animated: false, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
