//
//  DCOneThirdCalendarStripCollectionCell.swift
//  DrugChart
//
//  Created by aliya on 27/11/15.
//
//

import Foundation

class DCOneThirdCalendarStripCollectionCell: UICollectionViewCell {

    var indicatorLabel: UILabel = UILabel()
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func addTodayIndicator() {
        
        let today : NSDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd" as String
        let dateString = dateFormatter.stringFromDate(today)
        indicatorLabel.frame = CGRectMake(0,0, 25, 25)
        indicatorLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        indicatorLabel.font = UIFont.systemFontOfSize(17)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.text = dateString
        indicatorLabel.backgroundColor = UIColor(forHexString: "#007aff")
        indicatorLabel.layer.cornerRadius = 12.5
        indicatorLabel.layer.masksToBounds = true
        self.addSubview(indicatorLabel)
        self.bringSubviewToFront(indicatorLabel)
    }

}