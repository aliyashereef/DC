//
//  BarGraphCell.swift
//  DrugChart
//
//  Created by Noureen on 16/12/2015.
//
//

import UIKit

class BarGraphCell: GraphCollectionnViewCell {

    @IBOutlet weak var barGraph: BarGraphView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.graphView = barGraph
        
    }

}
