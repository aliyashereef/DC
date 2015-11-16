//
//  Helper.swift
//  vitalsigns
//
//  Created by Noureen on 17/09/2015.
//  Copyright (c) 2015 emishealth. All rights reserved.
//

import Foundation
import UIKit
class Helper
{
    static func displayInChildView(subView:UIView , parentView:UIView)
    {
        for subUIView in parentView.subviews {
            subUIView.removeFromSuperview()
        }
        
        subView.frame = parentView.frame
        subView.frame.origin.x = 0
        subView.frame.origin.y = 0
        parentView.addSubview(subView)
    }
}