//
//  DCNotesAndReasonCell.swift
//  DrugChart
//
//  Created by aliya on 23/09/15.
//
//

import Foundation
import UIKit

@objc public protocol MoreButtonDelegate {
    
    func moreButtonPressed( isExpanded: Bool)
}

class DCNotesAndReasonCell: UITableViewCell {
    
    @IBOutlet var cellContentTypeLabel: UILabel!
    @IBOutlet var moreButtonWidthConstaint: NSLayoutConstraint!
    @IBOutlet var reasonLabelLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var reasonTextLabel: UILabel!
    @IBOutlet var reasonTextLabelTopSpaceConstraint: NSLayoutConstraint!
    var delegate: MoreButtonDelegate?
    var isNotesExpanded : Bool = false

    @IBAction func showMoreButtonPressed(sender: AnyObject) {
        print(self.isNotesExpanded)
        if(self.isNotesExpanded == false){
            self.isNotesExpanded == true
        } else {
            self.isNotesExpanded == false
        }
        print(isNotesExpanded)
        moreButtonPressed()
    }
    
    func moreButtonPressed() {
        if let delegate = self.delegate {
            delegate.moreButtonPressed(self.isNotesExpanded)
        }
    }
}

