//
//  BarGraphCell.swift
//  DrugChart
//
//  Created by Noureen on 16/12/2015.
//
//

import UIKit

class BarGraphCell: GraphCollectionnViewCell , ObservationDelegate{

    @IBOutlet weak var barGraph: BarGraphView!
    var delegate:ObservationDelegate? = nil
    var cellObservationType:DashBoardRow!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.graphView = barGraph
        barGraph.observationDelegate = self
        registerDoubleTap()
    }
    
    func ShowPopOver(viewController: UIViewController)
    {
        delegate?.ShowPopOver(viewController)
    }
    
    override func showIndividualGraph()
    {
        
        let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
        let singlebarGraphController : SingleBarGraphController = mainStoryboard.instantiateViewControllerWithIdentifier("SingleBarGraphController") as! SingleBarGraphController
        singlebarGraphController.observationType = cellObservationType
        delegate?.PushViewController(singlebarGraphController)
    }

}
