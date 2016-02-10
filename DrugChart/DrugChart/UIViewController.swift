//
//  UIViewController.swift
//  DrugChart
//
//  Created by Noureen on 09/02/2016.
//
//

import Foundation

extension UIViewController {
    
    func startActivityIndicator(mainView:UIView)
    {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        activityIndicator.center = mainView.center
        activityIndicator.startAnimating()
        mainView.addSubview(activityIndicator)
    }
    
    func stopActivityIndicator(activityIndicator:UIActivityIndicatorView)
    {
        activityIndicator.stopAnimating()
    }
    
}