//
//  DCNotesAndReasonCell.swift
//  DrugChart
//
//  Created by aliya on 23/09/15.
//
//

import Foundation
import UIKit

class DCNotesAndReasonCell: UITableViewCell {
    
    @IBOutlet var cellContentTypeLabel: UILabel!
    @IBOutlet var moreButtonWidthConstaint: NSLayoutConstraint!
    @IBOutlet var reasonLabelLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var reasonTextLabel: UILabel!
    @IBOutlet var reasonTextLabelTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var moreButton: UIButton!
    var isNotesExpanded : Bool = false
}

