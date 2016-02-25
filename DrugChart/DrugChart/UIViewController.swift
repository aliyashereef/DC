//
//  UIViewController.swift
//  DrugChart
//
//  Created by Noureen on 09/02/2016.
//
//

import Foundation
import CocoaLumberjack

extension UIViewController {
    
    func startActivityIndicator(mainView:UIView) -> UIActivityIndicatorView
    {
        DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) Starting activity indicator ")
        let activityIndicator =  UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        activityIndicator.center = mainView.center
        activityIndicator.startAnimating()
        mainView.addSubview(activityIndicator)
        return activityIndicator
    }
    
    func stopActivityIndicator(activityIndicator:UIActivityIndicatorView!)
    {
        DDLogInfo("\(Constant.VITAL_SIGN_LOGGER_INDICATOR) Stopping activity indicator ")
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}