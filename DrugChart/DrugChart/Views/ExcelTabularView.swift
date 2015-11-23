//
//  ExcelTabularView.swift
//  DrugChart
//
//  Created by Noureen on 19/11/2015.
//
//

import UIKit

class ExcelTabularView: UIView , UICollectionViewDataSource, UICollectionViewDelegate {

    
    let dateCellIdentifier = "DateCellIdentifier"
    let contentCellIdentifier = "ContentCellIdentifier"
    @IBOutlet weak var collectionView: UICollectionView!
    var observationList:[VitalSignObservation]!
    
    func configureView(observationList:[VitalSignObservation])
    {
        self.observationList = observationList
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView .registerNib(UINib(nibName: "HeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: dateCellIdentifier)
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
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let headerCell : HeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(dateCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
            headerCell.configureCell()
            
            if indexPath.row == 0 {
                headerCell.label.text = "Date"
                return headerCell
            } else {
                let observation = observationList[indexPath.row - 1]
                headerCell.label.text = observation.getFormattedDate()
                return headerCell
            }
        } else {
            if indexPath.row == 0 {
                let headerCell : HeaderCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(dateCellIdentifier, forIndexPath: indexPath) as! HeaderCollectionViewCell
                
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
                case ObservationTabularViewRow.BM.rawValue:
                    headerText = Constant.BM
                default:
                    headerText = ""
                 }
                headerCell.label.text = headerText
                return headerCell
            } else {
                let contentCell : ContentCollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = UIFont.systemFontOfSize(13)
                contentCell.contentLabel.textColor = UIColor.blackColor()
                contentCell.contentLabel.text = "Content"
                contentCell.layer.borderWidth = 0.75
                contentCell.layer.borderColor = UIColor.lightGrayColor().CGColor
                if indexPath.section % 2 != 0 {
                    contentCell.backgroundColor = UIColor(white: 242/255.0, alpha: 1.0)
                } else {
                    contentCell.backgroundColor = UIColor.whiteColor()
                }
                
                return contentCell
            }
        }
    }
}
