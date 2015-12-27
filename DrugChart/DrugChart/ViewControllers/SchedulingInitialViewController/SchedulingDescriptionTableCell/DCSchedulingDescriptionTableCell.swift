//
//  DCSchedulingDescriptionTableCell.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 12/2/15.
//
//

import UIKit


class DCSchedulingDescriptionTableCell: DCInstructionsTableCell {
    
     @IBOutlet weak var descriptionTextView: UITextView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
      //  descriptionTextView.font = UIFont.systemFontOfSize(15.0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
