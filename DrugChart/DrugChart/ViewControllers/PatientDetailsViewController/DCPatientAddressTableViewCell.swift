//
//  DCPatientAddressTableViewCell.swift
//  DrugChart
//
//  Created by Jagajith M Kalarickal on 24/05/16.
//
//

import UIKit

class DCPatientAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var patientAddressLabel: UILabel!
    @IBOutlet weak var viewMapButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
