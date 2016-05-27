//
//  DCSummaryButton.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 2/3/16.
//
//

import UIKit

class DCSummaryButton: UIButton {

    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                self.backgroundColor = UIColor(forHexString :"#e8e8e8")
            } else {
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }

}
