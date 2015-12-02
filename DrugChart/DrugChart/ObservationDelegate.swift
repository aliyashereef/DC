//
//  File.swift
//  vitalsigns
//
//  Created by Noureen on 03/11/2015.
//  Copyright © 2015 emishealth. All rights reserved.
//

import Foundation
import UIKit

protocol ObservationDelegate
{
    func EditObservation(navigationController:UINavigationController)
    func TakeObservationInput(viewController:UIAlertController)
}

extension ObservationDelegate
{
    func EditObservation(navigationController:UINavigationController){}
    func TakeObservationInput(viewController:UIAlertController){}
}