//
//  DCDosageSelectionTableViewCell.swift
//  DrugChart
//
//  Created by Shaheer on 10/12/15.
//
//

import UIKit

class DCDosageSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var dosageMenuLabel: UILabel!
    @IBOutlet weak var dosageDetailLabel: UILabel!
    @IBOutlet weak var dosageDetailValueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(cellTitle:String,selectedValue:String) {
        
        dosageDetailLabel.text = cellTitle
        dosageDetailValueLabel.text = selectedValue
    }


}
