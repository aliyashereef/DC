//
//  DCAdministerButton.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 10/20/15.
//
//

import UIKit

class DCAdministerButton: UIButton {
    
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
