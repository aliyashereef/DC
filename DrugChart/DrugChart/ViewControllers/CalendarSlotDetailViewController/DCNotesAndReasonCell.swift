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
    
    func moreButtonPressed( selectedIndexPath : NSIndexPath)
}

class DCNotesAndReasonCell: UITableViewCell {
    
    @IBOutlet var cellContentTypeLabel: UILabel!
    @IBOutlet var moreButtonWidthConstaint: NSLayoutConstraint!
    @IBOutlet var reasonLabelLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var reasonTextLabel: UILabel!
    @IBOutlet var reasonTextLabelTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var moreButton: UIButton!
    var delegate: MoreButtonDelegate?
    var isNotesExpanded : Bool = false
    var selectedRowIndex: NSIndexPath = NSIndexPath(forRow: -1, inSection: 0)
    
    @IBAction func showMoreButtonPressed(sender: AnyObject) {
        
        if self.isNotesExpanded {
            self.isNotesExpanded = false
        } else {
            self.isNotesExpanded = true
        }

        switch(sender.tag){
        case 5:
            self.selectedRowIndex = NSIndexPath(forRow: 5, inSection: 1)
            break
        case 1:
            self.selectedRowIndex = NSIndexPath(forRow: 1, inSection: 2)
            break
        case 2:
            self.selectedRowIndex = NSIndexPath(forRow: 2, inSection: 3)
            break
        default:
            break
        }
        moreButtonPressed()
    }
    
    func moreButtonPressed() {
        if let delegate = self.delegate {
            delegate.moreButtonPressed(self.selectedRowIndex)
        }
    }
}

