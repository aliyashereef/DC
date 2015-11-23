//
//  ExcelTabularView.swift
//  DrugChart
//
//  Created by Noureen on 19/11/2015.
//
//

import UIKit

class ExcelTabularView: UIView , UICollectionViewDataSource, UICollectionViewDelegate {

    
    let headerCellIdentifier = "headerCellIdentifier"
    let contentCellIdentifier = "ContentCellIdentifier"
    @IBOutlet weak var collectionView: UICollectionView!
    var observationList:[VitalSignObservation]!
    
    func configureView(observationList:[VitalSignObservation])
    {
        self.observationList = observationList
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView .registerNib(UINib(nibName: "HeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: headerCellIdentifier)
        self.collectionView .registerNib(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
    }
    
    func reloadView(observationList:[VitalSignObservation])
    {
        let collectionViewLayOut = self.collectionView.collectionViewLayout as! CustomCollectionViewLayout
        self.observationList = observationList
        collectionViewLayOut.setNoOfColumns(observationList.count + 1)
        self.collectionView.reloadData()
    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ExcelTabularView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    // MARK - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 7
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ( observationList.count + 1 )
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(165,35)
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let headerCell : HeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(headerCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
            headerCell.configureCell()
            
            if indexPath.row == 0 {
                headerCell.dateLabel.text = "Date"
                return headerCell
            } else {
                let observation = observationList[indexPath.row - 1]
                headerCell.dateLabel.text = observation.getFormattedDate()
                headerCell.timeLabel.text = observation.getFormattedTime()
                return headerCell
            }
        } else {
            if indexPath.row == 0 {
                let headerCell : HeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(headerCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
                
                headerCell.configureCell()
                var headerText:String
                
                switch(indexPath.section)
                {
                case ObservationTabularViewRow.Respiratory.rawValue:
                    headerText = Constant.RESPIRATORY
                case ObservationTabularViewRow.SPO2.rawValue:
                    headerText = Constant.SPO2
                case ObservationTabularViewRow.Temperature.rawValue:
                    headerText = Constant.TEMPERATURE
                case ObservationTabularViewRow.BloodPressure.rawValue:
                    headerText = Constant.BLOOD_PRESSURE
                case ObservationTabularViewRow.Pulse.rawValue:
                    headerText = Constant.PULSE
                case ObservationTabularViewRow.BM.rawValue:
                    headerText = Constant.BM
                default:
                    headerText = ""
                 }
                headerCell.dateLabel.text = headerText
                return headerCell
            } else {
                let contentCell : ContentCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.configureCell()
                let observation = observationList[indexPath.row - 1]
                switch(indexPath.section)
                {
                case ObservationTabularViewRow.Respiratory.rawValue:
                    contentCell.contentLabel.text = observation.getRespiratoryReading()
                case ObservationTabularViewRow.SPO2.rawValue:
                    contentCell.contentLabel.text = observation.getSpo2Reading()
                case ObservationTabularViewRow.Temperature.rawValue:
                     contentCell.contentLabel.text = observation.getTemperatureReading()
                case ObservationTabularViewRow.BloodPressure.rawValue:
                     contentCell.contentLabel.text = observation.getBloodPressureReading()
                case ObservationTabularViewRow.Pulse.rawValue:
                    contentCell.contentLabel.text = observation.getPulseReading()
                case ObservationTabularViewRow.BM.rawValue:
                    contentCell.contentLabel.text = observation.getBMReading()
                default:
                  print("come in default section")
                }
                return contentCell
            }
        }
    }
}
