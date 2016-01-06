//
//  LineGraphCell.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//

import UIKit

class LineGraphCell: GraphCollectionnViewCell {

    @IBOutlet weak var lineGraph: LineGraphView!
    var delegate:ObservationDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.graphView = lineGraph
        
        super.registerSingleTap()
    }
    
    override func showIndividualGraph()
    {
//        let alert = UIAlertView()
//        alert.title = "my title"
//        alert.message = "things are working slowly"
//        alert.addButtonWithTitle("Ok")
//        alert.delegate = self
//        alert.show()
        
        
        let mainStoryboard = UIStoryboard(name: "PatientMenu", bundle: NSBundle.mainBundle())
        let singleLineGraphController : SingleLineGraphController = mainStoryboard.instantiateViewControllerWithIdentifier("SingleLineGraphController") as! SingleLineGraphController
        delegate?.PushViewController(singleLineGraphController)
    }

}
