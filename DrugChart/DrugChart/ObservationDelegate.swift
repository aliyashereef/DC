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
    func ShowModalNavigationController(navigationController:UINavigationController)
    func TakeObservationInput(viewController:UIAlertController)
    func ShowModalViewController(viewController:UIViewController)
    func DateSelected(value:NSDate)
    func GetLatestObservation(dataType:DashBoardRow)->VitalSignObservation!
    func PushViewController(navigationController:UIViewController)
    func ShowAlertController(alertController:UIAlertController)
    func ShowPopOver(viewController:UIViewController)
}

extension ObservationDelegate
{
    func ShowModalNavigationController(navigationController:UINavigationController){}
    func TakeObservationInput(viewController:UIAlertController){}
    func ShowModalViewController(viewController:UIViewController){}
    func DateSelected(value:NSDate){}
    func GetLatestObservation(dataType:DashBoardRow)->VitalSignObservation! { return nil}
    func PushViewController(navigationController:UIViewController){}
    func ShowAlertController(alertController:UIAlertController) {}
    func ShowPopOver(viewController:UIViewController){}
}