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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.graphView = lineGraph
    }
    
}
