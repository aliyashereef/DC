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
    func EditObservationViewController(viewController:UIViewController)
    func DateSelected(value:NSDate)
    func GetLatestObservation(dataType:DashBoardRow)->VitalSignObservation!

}

extension ObservationDelegate
{
    func EditObservation(navigationController:UINavigationController){}
    func TakeObservationInput(viewController:UIAlertController){}
    func EditObservationViewController(viewController:UIViewController){}
    func DateSelected(value:NSDate){}
    func GetLatestObservation(dataType:DashBoardRow)->VitalSignObservation! { return nil}
}