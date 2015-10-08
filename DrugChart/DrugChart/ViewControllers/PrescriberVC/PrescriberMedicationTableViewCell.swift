//
//  PrescriberMedicationTableViewCell.swift
//  DrugChart
//
//  Created by Muhammed Shaheer on 05/10/15.
//
//

import UIKit

//protocol PrescriberMedicationTableViewCellDelegate:class {
//    
//    func tableCellSwipedToLeftDirection()
//    func tableCellSwipedToRightDirection()
//}

class PrescriberMedicationTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var medicineDetailHolderView: UIView!
    @IBOutlet weak var medicineName: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var instructions: UILabel!
    
    @IBOutlet weak var administerDetailsHolderView: UIView!
    @IBOutlet weak var masterMedicationAdministerDetailsView : UIView!
    @IBOutlet weak var leftMedicationAdministerDetailsView: UIView!
    @IBOutlet weak var rightMedicationAdministerDetailsView: UIView!
    
    // this is the constraint connected between the masterMedicationAdministerDetailsView (center)
    // to the containerView holding the 3 subviews (left, right, center)
    // To move the calendar left/right only this constant value needs to be changed.
    @IBOutlet weak var leadingSpaceMasterToContainerView: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
