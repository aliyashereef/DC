//
//  LineGraphCell.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//

import UIKit

class LineGraphCell: GraphCollectionnViewCell , ObservationDelegate {

    @IBOutlet weak var lineGraph: LineGraphView!
    var delegate:ObservationDelegate? = nil
    var cellObservationType:DashBoardRow!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.graphView = lineGraph
        lineGraph.observationDelegate = self
        super.registerDoubleTap()
    }
    
    
    
    func ShowPopOver(viewController: UIViewController)
    {
        delegate?.ShowPopOver(viewController)
    }
    
    override func showIndividualGraph()
    {
        
        let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
        let singleLineGraphController : SingleLineGraphController = mainStoryboard.instantiateViewControllerWithIdentifier("SingleLineGraphController") as! SingleLineGraphController
        singleLineGraphController.observationType = cellObservationType
        delegate?.PushViewController(singleLineGraphController)
    }

}
