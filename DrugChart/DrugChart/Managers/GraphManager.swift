//
//  GraphManager.swift
//  DrugChart
//
//  Created by Noureen on 11/12/2015.
//
//

import UIKit

class GraphManager
{
   static func graphSize() -> CGSize
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad &&
          (  UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)
        
        {
            return CGSizeMake(400,320)

        }
        else 
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad &&
        UIDevice.currentDevice().orientation == .Portrait
        {
            return CGSizeMake(350,320)
        }
        else
        {
            return CGSizeMake(308,264)
        }
    }
}