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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func addTodayIndicatorInCell() {
        
        let today : NSDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd" as String
        let dateString = dateFormatter.stringFromDate(today)
        indicatorLabel.frame = CGRectMake(0,0, 20, 20)
        indicatorLabel.center =  dateLabel.center
        indicatorLabel.font = UIFont.systemFontOfSize(13)
        indicatorLabel.textAlignment = .Center
        indicatorLabel.textColor = UIColor.whiteColor()
        indicatorLabel.text = dateString
        indicatorLabel.backgroundColor = UIColor(forHexString: "#007aff")
        indicatorLabel.layer.cornerRadius = 10
        indicatorLabel.layer.masksToBounds = true
        self.addSubview(indicatorLabel)
        self.bringSubviewToFront(indicatorLabel)
        self.layoutIfNeeded()
    }

}