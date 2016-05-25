//
//  DCPatientPhoneEmailTableViewCell.swift
//  DrugChart
//
//  Created by Jagajith M Kalarickal on 24/05/16.
//
//

import UIKit

class DCPatientPhoneEmailTableViewCell: UITableViewCell {

    @IBOutlet weak var homeNumberLabel: UILabel!
    @IBOutlet weak var workNumberLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
