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
    let contentCellIdentifier = "contentCellIdentifier"
    let rowHeaderCellIdentifier = "rowHeaderCellIdentifier"
    
    @IBOutlet weak var collectionView: UICollectionView!
    var observationList:[VitalSignObservation]!
    
    func configureView(observationList:[VitalSignObservation])
    {
        self.observationList = observationList
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView .registerNib(UINib(nibName: "HeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: headerCellIdentifier)
        self.collectionView .registerNib(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)

        self.collectionView .registerNib(UINib(nibName: "RowHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: rowHeaderCellIdentifier)

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
        return ObservationTabularViewRow.count
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ( observationList.count + 1 )
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let headerCell : HeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(headerCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
            headerCell.configureCell()
            
            if indexPath.row == 0 {
                headerCell.dateLabel.text = "Date"
                headerCell.timeLabel.text = "Time"
                headerCell.backgroundColor = UIColor(red: 31/255, green: 146/255, blue: 190/255, alpha: 1.0)
                return headerCell
            } else {
                let observation = observationList[indexPath.row - 1]
                headerCell.dateLabel.text = observation.getFormattedDate()
                headerCell.timeLabel.text = observation.getFormattedTime()
                headerCell.backgroundColor = UIColor(red: 31/255, green: 146/255, blue: 190/255, alpha: 1.0)
                return headerCell
            }
        } else {
            if indexPath.row == 0 {
                let headerCell : RowHeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(rowHeaderCellIdentifier, forIndexPath: indexPath) as! RowHeaderCollectionViewCell
                
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
                case ObservationTabularViewRow.News.rawValue:
                    headerText = Constant.NEWS
                case ObservationTabularViewRow.CommaScore.rawValue:
                    headerText = Constant.COMMA_SCORE
                default:
                    headerText = ""
                 }
                headerCell.backgroundColor = UIColor.whiteColor()
                
                headerCell.label.text = headerText
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
                case ObservationTabularViewRow.News.rawValue:
                    contentCell.contentLabel.text = observation.getNews()
                case ObservationTabularViewRow.CommaScore.rawValue:
                    contentCell.contentLabel.text = observation.getComaScore()
                default:
                  print("come in default section")
                }
                contentCell.backgroundColor = UIColor.whiteColor()
                return contentCell
            }
        }
    }
}
