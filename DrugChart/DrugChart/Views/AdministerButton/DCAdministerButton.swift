//
//  DCAdministerButton.swift
//  DrugChart
//
//  Created by Jilu Mary Joy on 10/20/15.
//
//

import UIKit

class DCAdministerButton: UIButton {
    
    let appDelegate : DCAppDelegate = UIApplication.sharedApplication().delegate as! DCAppDelegate

    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                if (appDelegate.windowState == DCWindowState.halfWindow || appDelegate.windowState == DCWindowState.oneThirdWindow) {
                    self.backgroundColor = UIColor.clearColor()
                } else {
                    self.backgroundColor = UIColor(forHexString :"#e8e8e8")
                }
            } else {
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
}
